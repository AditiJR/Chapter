import 'package:go_router/go_router.dart';

import '../model/book.dart';
import '../pages/book_details/book_details_page.dart';
import '../pages/chat/chat_page.dart';
import '../pages/edit_profile/edit_profile_page.dart';
import '../pages/edit_top_five/edit_top_five_page.dart';
import '../pages/premium/premium_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/friend_profile/friend_profile_page.dart';
import '../pages/friends/friends_page.dart';
import '../pages/messages/messages_page.dart';
import '../pages/notifications/notifications_page.dart';
import '../pages/library/library_empty_page.dart';
import '../pages/library/library_home_page.dart';
import '../pages/library/shelf_detail_page.dart';
import '../pages/onboarding/onboarding_page.dart';
import '../pages/permissions/permissions_page.dart';
import '../pages/scan/scan_page.dart';
import '../pages/search/search_page.dart';
import '../pages/reset_password/reset_link_sent_page.dart';
import '../pages/reset_password/reset_password_page.dart';
import '../pages/sign_up/sign_up_page.dart';
import '../pages/sign_in/sign_in_page.dart';
import '../pages/splash/splash_page.dart';
import '../blocs/authentication/authentication_bloc.dart';
import '../utilities/stream_to_listenable.dart';
import '../widgets/scaffold_with_nav_bar.dart';
import 'my_navigator_route.dart';

/// Screens reachable without being signed in.
final _publicPaths = {
  MyNavigatorRoute.splash.path,
  MyNavigatorRoute.onboarding.path,
  MyNavigatorRoute.signIn.path,
  MyNavigatorRoute.signUp.path,
  MyNavigatorRoute.resetPassword.path,
  MyNavigatorRoute.resetLinkSent.path,
};

GoRouter buildRouter(AuthenticationBloc authBloc) => GoRouter(
  initialLocation: MyNavigatorRoute.splash.path,
  refreshListenable: StreamToListenable([authBloc.stream]),
  redirect: (context, state) {
    final signedIn = authBloc.isAuthenticated;
    if (!signedIn && !_publicPaths.contains(state.matchedLocation)) {
      return MyNavigatorRoute.signIn.path;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: MyNavigatorRoute.splash.path,
      name: MyNavigatorRoute.splash.name,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: MyNavigatorRoute.onboarding.path,
      name: MyNavigatorRoute.onboarding.name,
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: MyNavigatorRoute.signIn.path,
      name: MyNavigatorRoute.signIn.name,
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      path: MyNavigatorRoute.signUp.path,
      name: MyNavigatorRoute.signUp.name,
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
      path: MyNavigatorRoute.resetPassword.path,
      name: MyNavigatorRoute.resetPassword.name,
      builder: (context, state) => const ResetPasswordPage(),
    ),
    GoRoute(
      path: MyNavigatorRoute.resetLinkSent.path,
      name: MyNavigatorRoute.resetLinkSent.name,
      builder: (context, state) => const ResetLinkSentPage(),
    ),
    GoRoute(
      path: MyNavigatorRoute.permissions.path,
      name: MyNavigatorRoute.permissions.name,
      builder: (context, state) => const PermissionsPage(),
    ),
    GoRoute(
      path: MyNavigatorRoute.bookDetails.path,
      name: MyNavigatorRoute.bookDetails.name,
      builder: (context, state) => BookDetailsPage(
        title: state.pathParameters['title'] ?? 'Piranesi',
        book: state.extra as Book?,
      ),
    ),
    GoRoute(
      path: MyNavigatorRoute.messages.path,
      name: MyNavigatorRoute.messages.name,
      builder: (context, state) => const MessagesPage(),
    ),
    GoRoute(
      path: MyNavigatorRoute.chat.path,
      name: MyNavigatorRoute.chat.name,
      builder: (context, state) => ChatPage(
        uid: state.pathParameters['uid'] ?? '',
        name: state.extra as String?,
      ),
    ),
    GoRoute(
      path: MyNavigatorRoute.friendProfile.path,
      name: MyNavigatorRoute.friendProfile.name,
      builder: (context, state) =>
          FriendProfilePage(name: state.pathParameters['name'] ?? 'Maya Chen'),
    ),
    GoRoute(
      path: MyNavigatorRoute.notifications.path,
      name: MyNavigatorRoute.notifications.name,
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: MyNavigatorRoute.settings.path,
      name: MyNavigatorRoute.settings.name,
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: MyNavigatorRoute.editProfile.path,
      name: MyNavigatorRoute.editProfile.name,
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      path: MyNavigatorRoute.editTopFive.path,
      name: MyNavigatorRoute.editTopFive.name,
      builder: (context, state) => const EditTopFivePage(),
    ),
    GoRoute(
      path: MyNavigatorRoute.premium.path,
      name: MyNavigatorRoute.premium.name,
      builder: (context, state) => const PremiumPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ScaffoldWithNavBar(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: MyNavigatorRoute.library.path,
              name: MyNavigatorRoute.library.name,
              builder: (context, state) => const LibraryHomePage(),
              routes: [
                GoRoute(
                  path: MyNavigatorRoute.libraryEmpty.path,
                  name: MyNavigatorRoute.libraryEmpty.name,
                  builder: (context, state) => const LibraryEmptyPage(),
                ),
                GoRoute(
                  path: MyNavigatorRoute.shelfDetail.path,
                  name: MyNavigatorRoute.shelfDetail.name,
                  builder: (context, state) => ShelfDetailPage(
                    shelfId: state.pathParameters['id'] ?? '',
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: MyNavigatorRoute.search.path,
              name: MyNavigatorRoute.search.name,
              builder: (context, state) => const SearchPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: MyNavigatorRoute.scan.path,
              name: MyNavigatorRoute.scan.name,
              builder: (context, state) => const ScanPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: MyNavigatorRoute.friends.path,
              name: MyNavigatorRoute.friends.name,
              builder: (context, state) => const FriendsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: MyNavigatorRoute.profile.path,
              name: MyNavigatorRoute.profile.name,
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
