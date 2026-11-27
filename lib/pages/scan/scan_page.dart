import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../navigation/my_navigator_route.dart';
import '../../repositories/books/books_repository.dart';
import '../../theme/theme.dart';
import 'views/manual_entry_sheet.dart';
import 'views/scan_result_sheet.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  final _controller = MobileScannerController(
    autoStart: false,
    formats: const [BarcodeFormat.ean13],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  PermissionStatus? _permission;
  bool _tabVisible = true;
  bool _running = false;
  bool _loading = false;

  /// The last barcode handled, so a book left in view is not re-scanned
  /// right after its sheet closes.
  String? _lastCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermission();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The tab bar keeps every tab alive, so the camera is only on while this
    // tab is the one showing.
    final visible = TickerMode.valuesOf(context).enabled;
    if (visible != _tabVisible) {
      _tabVisible = visible;
      _syncCamera();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // The user may have just changed the permission in Settings.
      _refreshPermission();
    } else if (state == AppLifecycleState.paused) {
      _stopCamera();
    }
  }

  Future<void> _refreshPermission() async {
    final status = await Permission.camera.status;
    if (!mounted) return;
    setState(() => _permission = status);
    _syncCamera();
  }

  Future<void> _requestPermission() async {
    if (_permission?.isPermanentlyDenied ?? false) {
      await openAppSettings();
      return;
    }
    final status = await Permission.camera.request();
    if (!mounted) return;
    setState(() => _permission = status);
    _syncCamera();
  }

  void _syncCamera() {
    if (_tabVisible && (_permission?.isGranted ?? false)) {
      _startCamera();
    } else {
      _stopCamera();
    }
  }

  Future<void> _startCamera() async {
    if (_running) return;
    _running = true;
    try {
      await _controller.start();
    } catch (_) {
      // Shown by the scanner's errorBuilder.
      _running = false;
    }
  }

  Future<void> _stopCamera() async {
    if (!_running) return;
    _running = false;
    try {
      await _controller.stop();
    } catch (_) {}
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_loading) return;
    final raw = capture.barcodes
        .map((b) => b.rawValue)
        .whereType<String>()
        .map(GoogleBooksRepository.asIsbn)
        .whereType<String>()
        .firstOrNull;
    if (raw == null || raw == _lastCode) return;
    _lastCode = raw;
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final book = await context.read<BooksRepository>().findByIsbn(raw);
      if (!mounted) return;
      if (book == null) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('No book found for that barcode.')),
          );
      } else {
        await showScanResultSheet(context, book);
      }
    } on BooksException catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: ChapterColors.onSurface,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _RoundButton(
                      icon: 'assets/icons/x_light.svg',
                      onTap: () => context.go(MyNavigatorRoute.library.path),
                    ),
                    Expanded(
                      child: Text(
                        'Scan a book',
                        textAlign: TextAlign.center,
                        style: ChapterText.titleLarge.copyWith(
                          color: ChapterColors.onPrimary,
                        ),
                      ),
                    ),
                    _RoundButton(
                      icon: 'assets/icons/zap.svg',
                      onTap: () {
                        if (_running) _controller.toggleTorch();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: ChapterColors.cameraBackground,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Viewfinder(
                        loading: _loading,
                        controller: _controller,
                        permission: _permission,
                        onDetect: _onDetect,
                        onAllow: _requestPermission,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 280,
                        child: Opacity(
                          opacity: 0.9,
                          child: Text(
                            'Point the camera at the barcode on the back cover',
                            textAlign: TextAlign.center,
                            style: ChapterText.bodyLarge.copyWith(
                              color: ChapterColors.onPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Material(
                        color: const Color(0x29FFFFFF),
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => showManualEntrySheet(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/search_light.svg',
                                  width: 18,
                                  height: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Enter title or ISBN instead',
                                  style: ChapterText.labelLarge.copyWith(
                                    color: ChapterColors.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, this.onTap});

  final String icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x29FFFFFF),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset(icon, width: 24, height: 24),
        ),
      ),
    );
  }
}

class _Viewfinder extends StatelessWidget {
  const _Viewfinder({
    required this.loading,
    required this.controller,
    required this.permission,
    required this.onDetect,
    required this.onAllow,
  });

  final bool loading;
  final MobileScannerController controller;
  final PermissionStatus? permission;
  final void Function(BarcodeCapture) onDetect;
  final VoidCallback onAllow;

  Widget _corner() => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      border: Border.all(color: ChapterColors.onPrimary, width: 4),
      borderRadius: BorderRadius.circular(14),
    ),
  );

  Widget _message(String text, {String? action}) => Center(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: ChapterText.bodyMedium.copyWith(
              color: ChapterColors.onPrimary,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onAllow,
              style: TextButton.styleFrom(
                foregroundColor: ChapterColors.onPrimary,
                backgroundColor: const Color(0x29FFFFFF),
              ),
              child: Text(action),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _camera() {
    final status = permission;
    if (status == null) {
      return const Center(
        child: CircularProgressIndicator(color: ChapterColors.onPrimary),
      );
    }
    if (status.isPermanentlyDenied) {
      return _message(
        'Camera access is turned off. Enable it in Settings to scan.',
        action: 'Open Settings',
      );
    }
    if (!status.isGranted) {
      return _message(
        'Chapter needs the camera to read book barcodes.',
        action: 'Allow camera',
      );
    }
    return MobileScanner(
      controller: controller,
      onDetect: onDetect,
      errorBuilder: (context, error) =>
          _message('Camera unavailable. Try searching by title or ISBN.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 200,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: ColoredBox(color: Colors.black, child: _camera()),
            ),
          ),
          Positioned(left: 0, top: 0, child: _corner()),
          Positioned(left: 236, top: 0, child: _corner()),
          Positioned(left: 0, top: 156, child: _corner()),
          Positioned(left: 236, top: 156, child: _corner()),
          if (permission?.isGranted ?? false)
            Positioned(
              left: 15,
              top: 98,
              child: Container(
                width: 250,
                height: 3,
                decoration: BoxDecoration(
                  color: ChapterColors.error,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          if (loading)
            const Center(
              child: CircularProgressIndicator(color: ChapterColors.onPrimary),
            ),
        ],
      ),
    );
  }
}
