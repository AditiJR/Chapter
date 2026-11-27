# Chapter

A book logging app built in Flutter, implemented from the "Chapter - Book logging app" Figma design. Scan or search for books, organize them on shelves, tag them, pin a Top 5, and message other readers.

## Features

- **Auth:** email/password and Google sign-in (Firebase Authentication), sign up, password reset, and a permissions screen for camera and notifications.
- **Library:** shelves, a currently-reading card, recently added books, and a shelf detail page. Your library is stored in Cloud Firestore, so it follows your account.
- **Scan and search:** a live camera barcode scanner (EAN-13 ISBNs), a "Find a book" sheet for typing a title or ISBN, and search. Books come from the Google Books API.
- **Book details:** move a book to a shelf, edit tags, pin it to your Top 5, or remove it.
- **Messaging:** real-time in-app chat between signed-in users, stored in Firestore.
- **Friends:** find readers, follow and unfollow, an activity feed of books the people you follow shelved, and live reader profiles (Top 5, shelves, follower counts). Stored in Firestore.
- **Notifications:** new followers and new messages arrive in the Notifications screen and as an in-app banner while the app is open, with an unread badge on the bell.
- **Push notifications:** Firebase Cloud Messaging (Android). Messages from the Firebase console arrive as pushes; the app does not send pushes itself, since that needs a server (Cloud Functions).
- **Profile:** edit your name, username and bio, which are saved to Firestore.

The only sample data left is the Popular books and Recent searches lists on the Search screen.

## Tech

- Flutter / Dart
- `go_router` for navigation, including a bottom-nav shell
- `flutter_bloc` and `equatable` for state
- Firebase: `firebase_auth`, `cloud_firestore`, `firebase_messaging`
- `mobile_scanner` and `permission_handler` for the camera
- `http` for the Google Books API
- `flutter_svg` and `google_fonts` (Lora and Roboto)

## Project structure

```
lib/
  main.dart
  blocs/          authentication and library state
  config/         secrets.dart (gitignored) and secrets.example.dart
  model/          Book, AppUser, UserProfile, Chat, Friend
  navigation/     enhanced-enum routes (MyNavigatorRoute) and router.dart
  pages/          one folder per screen, with a views/ subfolder for its sheets
  repositories/   Firebase auth, Firestore library/users/chat, Google Books
  services/       notification service, sample data
  theme/          colors and text styles from the Figma tokens
  widgets/        shared components
assets/
  icons/  illustrations/  avatars/   SVGs downloaded from Figma
```

## Setup

You need the Flutter SDK, an Android emulator or device, and a Firebase project.

### 1. Dependencies

```bash
flutter pub get
```

### 2. Firebase

1. Create a project at https://console.firebase.google.com and add an Android app with package name `edu.scu.chapter`.
2. Download `google-services.json` into `android/app/`.
3. Enable **Authentication** with the **Email/Password** and **Google** sign-in methods.
4. Create a **Cloud Firestore** database and publish the rules in `firestore.rules`, for example with `firebase deploy --only firestore:rules`.
5. Cloud Messaging needs no extra setup. To try a push, send a test message from Firebase console → Messaging to the device's registration token.

### 3. Google Books API key

1. Create an API key at https://console.cloud.google.com/apis/credentials and enable the **Books API** for the project.
2. Copy the template and paste your key into it:

```bash
cp lib/config/secrets.example.dart lib/config/secrets.dart
```

`secrets.dart` is gitignored, so the key is never committed. In Google Cloud, restrict the key to the Books API (and, if you like, to the Android app) so a leaked key can't be used for anything else.

### 4. Run

```bash
flutter run
```

To run on a specific device, use `flutter devices` to find its id, then `flutter run -d <id>`.

The camera scanner needs a device or emulator with a camera. The Android emulator's virtual camera shows a fixed scene, so use "Enter title or ISBN instead" there.

## Tests

```bash
flutter test
```
