# FitnessApp

A Flutter fitness tracker built around provider-based state, layered architecture, local persistence, live exercise data, and GPS outdoor workout tracking.

## Overview

The app combines indoor planning and outdoor tracking in one flow:

- browse live exercise categories
- load category exercise catalogs from API Ninjas
- search exercises by type and muscle
- create custom exercises and merge them into the catalog
- build and persist a local routine
- calculate BMI and manage a basic profile/assessment
- track outdoor workouts with GPS, timing, route points, and history

## Features

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
- Assessment/profile flow with persisted user data
- Outdoor workout tracking with:
  - location permission handling
  - live elapsed time
  - route point capture
  - distance-aware tracking
  - workout finish summary
  - persisted outdoor workout history

## Tech Stack

- Flutter
- Provider
- Dio
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

`lib/main.dart` wires dependencies with `Provider` and starts the app through [`AppRouter`](c:\Users\asus\fitnessapp\lib\presentation\navigation\app_router.dart).

## Key Files

- [`lib/main.dart`](c:\Users\asus\fitnessapp\lib\main.dart)
- [`lib/presentation/navigation/app_router.dart`](c:\Users\asus\fitnessapp\lib\presentation\navigation\app_router.dart)
- [`lib/presentation/screens/home_screen.dart`](c:\Users\asus\fitnessapp\lib\presentation\screens\home_screen.dart)
- [`lib/presentation/screens/exercise_browse_screen.dart`](c:\Users\asus\fitnessapp\lib\presentation\screens\exercise_browse_screen.dart)
- [`lib/presentation/screens/exercise_list_screen.dart`](c:\Users\asus\fitnessapp\lib\presentation\screens\exercise_list_screen.dart)
- [`lib/presentation/screens/exercise_search_screen.dart`](c:\Users\asus\fitnessapp\lib\presentation\screens\exercise_search_screen.dart)
- [`lib/presentation/screens/outdoor_workout_screen.dart`](c:\Users\asus\fitnessapp\lib\presentation\screens\outdoor_workout_screen.dart)
- [`lib/presentation/screens/outdoor_workout_history_screen.dart`](c:\Users\asus\fitnessapp\lib\presentation\screens\outdoor_workout_history_screen.dart)
- [`lib/data/repositories/exercise_api_repository.dart`](c:\Users\asus\fitnessapp\lib\data\repositories\exercise_api_repository.dart)
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
3. Run `flutter run`.

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

## Persistence

The app persists:

- saved routine entries
- user profile data
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
- The repository currently contains an older `libra/` directory that does not appear to be part of the active app entrypoint.
