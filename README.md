# Chapter

A book logging app built in Flutter, implemented from the "Chapter - Book logging app" Figma design. Scan or search for books, organize them on shelves, tag them, pin a Top 5, and follow friends.

> All data is mock data. There is no backend, so nothing is saved between runs.

## Features

- **Onboarding and auth:** animated splash, three onboarding slides, sign in, sign up, password reset, and permissions.
- **Library:** shelves, a currently-reading card, recently added books, and a shelf detail page with filters. Shelves can be created, edited, and deleted.
- **Scan and search:** a barcode scan screen with a "book found" sheet, plus search with recent searches and results.
- **Book details:** move a book to a shelf, edit tags, pin it to your Top 5, remove it, or open the buy sheet.
- **Social:** an activity feed, suggested readers, messages and chat, friend profiles, notifications, and an in-app push banner.
- **Profile:** edit your profile and Top 5, settings with notification toggles, sign out, and a Premium paywall.

## Tech

- Flutter / Dart
- `go_router` for navigation, including a bottom-nav shell
- `flutter_svg` for the icons and illustrations exported from Figma
- `google_fonts` (Lora and Roboto)
- `flutter_bloc` and `equatable`, added as dependencies

## Project structure

```
lib/
  main.dart
  navigation/   enhanced-enum routes (MyNavigatorRoute) and router.dart
  pages/        one folder per screen, with a views/ subfolder for its sheets and dialogs
  widgets/      shared components (buttons, chips, book cover, nav bar, dialogs)
  model/        Book, Friend
  services/     mock.dart (mock data)
  theme/        colors and text styles from the Figma tokens
assets/
  icons/  illustrations/  avatars/   SVGs downloaded from Figma
```

## Running

Requires the Flutter SDK.

```bash
flutter pub get
flutter run
```

To run on a specific device, use `flutter devices` to find its id, then `flutter run -d <id>`.
