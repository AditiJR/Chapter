import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/my_navigator_route.dart';
import '../../repositories/books/books_repository.dart';
import '../../theme/theme.dart';
import 'views/scan_result_sheet.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  /// ISBN the demo viewfinder "scans" until the camera scanner is wired in.
  static const _demoIsbn = '9781635575637';

  bool _loading = false;

  Future<void> _scan() async {
    if (_loading) return;
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final book = await context.read<BooksRepository>().findByIsbn(_demoIsbn);
      if (!mounted) return;
      if (book == null) {
        messenger.showSnackBar(
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
                    const _RoundButton(icon: 'assets/icons/zap.svg'),
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
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _scan,
                        child: _Viewfinder(loading: _loading),
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
                          onTap: () => context.go(MyNavigatorRoute.search.path),
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
  const _Viewfinder({this.loading = false});

  final bool loading;

  Widget _corner() => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      border: Border.all(color: ChapterColors.onPrimary, width: 4),
      borderRadius: BorderRadius.circular(14),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 200,
      child: Stack(
        children: [
          Positioned(left: 0, top: 0, child: _corner()),
          Positioned(left: 236, top: 0, child: _corner()),
          Positioned(left: 0, top: 156, child: _corner()),
          Positioned(left: 236, top: 156, child: _corner()),
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
