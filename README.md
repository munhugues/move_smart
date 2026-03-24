# Move Smart

Move Smart is a Flutter app focused on reducing queue uncertainty in Kigali public transport by enabling trip and seat booking flows.

## Member 1 Scope (Identity & Access)

Implemented:

- Welcome, Login, Signup, Profile, and Settings UI flow
- Global authentication state gate (logged-in vs logged-out)
- Auth methods:
  - Email/Password
  - Google sign-in
  - Apple sign-in (iOS/macOS)
- Firestore users collection sync on sign-in/sign-up
- Local persistence (`SharedPreferences`) for:
  - Login session info/token
  - Language preference
  - Dark mode preference
- Unit tests for email/password validation logic

## Run Locally

1. Install dependencies:

	`flutter pub get`

2. Run app:

	`flutter run`

## Firebase Setup

This codebase includes Firebase auth datasource implementation.

To fully enable production auth:

1. Create Firebase project.
2. Add Flutter apps (Android/iOS/Web/macOS as needed).
3. Configure Firebase files/options for each platform.
4. Enable providers in Firebase Authentication:
	- Email/Password
	- Google
	- Apple (Apple Developer setup required)
5. Create Firestore database (users collection will be created/updated automatically by app sign-in flows).

If Firebase is not configured yet, the app falls back to a local demo auth datasource for UI flow testing.

## Tests

Run:

`flutter test`
