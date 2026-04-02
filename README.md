# FitnessApp

A Flutter fitness tracker built around provider-based state, layered architecture, Firebase authentication, local persistence, live exercise data, and GPS outdoor workout tracking.

## Overview

The app combines indoor planning, account-aware personalization, and outdoor tracking in one flow:

- sign in or register with Firebase Email/Password
- continue as a guest with browsing-only access
- browse live exercise categories
- load category exercise catalogs from API Ninjas
- search exercises by type and muscle
- create custom exercises and merge them into the catalog
- build and persist a local routine
- calculate BMI and manage a persisted profile/assessment
- track outdoor workouts with GPS, timing, route points, history, and completion notifications

## Features

- Firebase authentication flow with:
  - registration
  - login
  - logout
  - password reset
  - persisted sessions
  - session validation on app launch
- Guest mode dashboard:
  - signed-out users can explore categories and exercise overviews
  - routine-building and profile actions stay locked until sign-in
- Home dashboard with workout categories:
  - `Strength`
  - `Cardio`
  - `Stretching`
  - `Plyometrics`
  - `Weightlifting`
  - `Strongman`
- API-backed `Exercise Browser` catalog by category
- API-backed category detail lists
- Live exercise search powered by API Ninjas and `dio`
- Exercise detail view with instructions, safety info, and equipment
- Custom exercise creation with validation and volume calculation
- Routine builder with local persistence via `shared_preferences`
- BMI calculator
- Assessment/profile flow with persisted user data and account-aware profile completion prompts
- Outdoor workout tracking with:
  - location permission handling
  - live elapsed time
  - route point capture
  - distance-aware tracking
  - workout finish summary
  - persisted outdoor workout history
  - workout completion notifications
- Notification support with:
  - Android/iOS system notifications for workout completion
  - in-app workout completion banner feedback
  - dynamic notification content based on workout stats

## Tech Stack

- Flutter
- Provider
- Firebase Core
- Firebase Auth
- Dio
- Flutter Local Notifications
- Shared Preferences
- Geolocator
- URL Launcher

## Architecture

The project follows a simple layered structure:

- `lib/data/`
  - repositories for remote and local persistence
  - services for platform/device access
  - reference data and in-memory stores
- `lib/domain/providers/`
  - app state and business logic with `ChangeNotifier`
- `lib/models/`
  - typed data models used across the app
- `lib/presentation/`
  - screens, widgets, and navigation

`lib/main.dart` wires dependencies with `Provider`, initializes Firebase plus notifications, and starts the app through [`AuthGate`](c:\Users\asus\fitnessapp\lib\presentation\navigation\auth_gate.dart).

## Key Files

- [`lib/main.dart`](c:\Users\asus\fitnessapp\lib\main.dart)
- [`lib/presentation/navigation/auth_gate.dart`](c:\Users\asus\fitnessapp\lib\presentation\navigation\auth_gate.dart)
- [`lib/presentation/navigation/app_router.dart`](c:\Users\asus\fitnessapp\lib\presentation\navigation\app_router.dart)
- [`lib/presentation/screens/login_screen.dart`](c:\Users\asus\fitnessapp\lib\presentation\screens\login_screen.dart)
- [`lib/presentation/screens/home_screen.dart`](c:\Users\asus\fitnessapp\lib\presentation\screens\home_screen.dart)
- [`lib/presentation/screens/exercise_browse_screen.dart`](c:\Users\asus\fitnessapp\lib\presentation\screens\exercise_browse_screen.dart)
- [`lib/presentation/screens/exercise_list_screen.dart`](c:\Users\asus\fitnessapp\lib\presentation\screens\exercise_list_screen.dart)
- [`lib/presentation/screens/exercise_search_screen.dart`](c:\Users\asus\fitnessapp\lib\presentation\screens\exercise_search_screen.dart)
- [`lib/presentation/screens/outdoor_workout_screen.dart`](c:\Users\asus\fitnessapp\lib\presentation\screens\outdoor_workout_screen.dart)
- [`lib/presentation/screens/outdoor_workout_history_screen.dart`](c:\Users\asus\fitnessapp\lib\presentation\screens\outdoor_workout_history_screen.dart)
- [`lib/data/services/auth_service.dart`](c:\Users\asus\fitnessapp\lib\data\services\auth_service.dart)
- [`lib/data/services/notification_service.dart`](c:\Users\asus\fitnessapp\lib\data\services\notification_service.dart)
- [`lib/data/repositories/exercise_api_repository.dart`](c:\Users\asus\fitnessapp\lib\data\repositories\exercise_api_repository.dart)
- [`lib/domain/providers/auth_provider.dart`](c:\Users\asus\fitnessapp\lib\domain\providers\auth_provider.dart)
- [`lib/domain/providers/workout_tracking_provider.dart`](c:\Users\asus\fitnessapp\lib\domain\providers\workout_tracking_provider.dart)

## Project Structure

```text
lib/
|-- main.dart
|-- verify_architecture.dart
|-- data/
|   |-- memory/
|   |-- models/
|   |-- reference/
|   |-- repositories/
|   |-- services/
|-- domain/
|   |-- providers/
|-- models/
|-- presentation/
|   |-- navigation/
|   |-- screens/
|   |-- widgets/
|-- utils/
```

## Getting Started

1. Install Flutter.
2. Run `flutter pub get`.
3. Configure Firebase for this project.
4. Enable Firebase Authentication with Email/Password.
5. Run `flutter run`.

## Firebase Setup

This app expects Firebase auth to be configured.

Required files already used by the project:

- [`lib/firebase_options.dart`](c:\Users\asus\fitnessapp\lib\firebase_options.dart)
- [`android/app/google-services.json`](c:\Users\asus\fitnessapp\android\app\google-services.json)
- [`ios/Runner/GoogleService-Info.plist`](c:\Users\asus\fitnessapp\ios\Runner\GoogleService-Info.plist)

Typical setup flow:

1. Create or select a Firebase project.
2. Enable `Authentication > Email/Password`.
3. Run `flutterfire configure`.
4. Confirm platform files and `firebase_options.dart` are generated.

## API Setup

The exercise catalog and search flows use API Ninjas.

Current implementation detail:

- the API key is currently stored directly in [`lib/data/repositories/exercise_api_repository.dart`](c:\Users\asus\fitnessapp\lib\data\repositories\exercise_api_repository.dart)

Recommended setup:

1. Create an API Ninjas account.
2. Generate an API key.
3. Replace the key in `ExerciseApiRepository`.
4. Prefer moving the key out of source control before production use.

## Location Setup

Outdoor workout tracking depends on `geolocator` and platform location permissions.

Android:

- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`

File:
- `android/app/src/main/AndroidManifest.xml`

iOS:

- `NSLocationWhenInUseUsageDescription`

File:
- `ios/Runner/Info.plist`

The app requests location access when the user starts an outdoor workout.

## Notification Setup

Workout completion notifications depend on `flutter_local_notifications`.

Android:

- `POST_NOTIFICATIONS`

File:
- [`android/app/src/main/AndroidManifest.xml`](c:\Users\asus\fitnessapp\android\app\src\main\AndroidManifest.xml)

Behavior:

- Android/iOS use system notifications for workout completion
- the app also shows an in-app top banner confirmation when a workout finishes
- desktop/web fallback relies on in-app feedback rather than OS notifications

## Persistence

The app persists:

- saved routine entries
- user profile data keyed to the signed-in user where available
- outdoor workout history

Persistence is handled primarily with `shared_preferences`.

## Verification

Architecture checks can be run with:

```bash
dart lib/verify_architecture.dart
```

This script validates some project boundaries, such as avoiding persistence imports in presentation code.

## Notes

- `Exercise Browser` now loads its category catalog from the API instead of local mock data.
- `Exercise List` and `Exercise Search` also use the API.
- Custom exercises are kept locally and merged into the relevant category views.
- Authentication is handled with Firebase Email/Password through a dedicated auth service/provider flow.
- The dashboard supports a guest mode for browsing, while routine and profile features require sign-in.
- The repository currently contains an older `libra/` directory that does not appear to be part of the active app entrypoint.
