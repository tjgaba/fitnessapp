# FitnessApp

A Flutter fitness tracker built around layered architecture, provider-based state, local persistence, API-backed exercise browsing, and a GPS outdoor workout flow.

## Overview

The app combines indoor training and outdoor tracking:

- browse API-backed workout categories
- search live exercises from API Ninjas
- create and save custom exercises
- build a local routine
- calculate BMI and assessments
- track outdoor workouts with GPS, timers, route points, and history

The codebase is organized so that:

- `models` define typed app data
- `data` handles repositories, services, and external/local data access
- `domain` manages state and business logic
- `presentation` contains screens, widgets, and navigation
- `main.dart` wires dependencies with `Provider`

## Features

- Dashboard with API-aligned workout categories:
  - `Strength`
  - `Cardio`
  - `Stretching`
  - `Plyometrics`
  - `Weightlifting`
  - `Strongman`
- API-backed category exercise lists
- Live exercise search powered by API Ninjas and `dio`
- Exercise detail views with instructions, equipment, and safety info
- Custom exercise creation with validation and live volume preview
- Routine builder with local persistence
- BMI calculator and profile/assessment flows
- Outdoor workout tracking with:
  - location permission handling
  - elapsed time tracking
  - current coordinate updates
  - finish summary
  - route point capture
  - route preview sketch
  - tappable route points that open coordinates externally
  - persisted outdoor workout history grouped by week

## Architecture

### Data Layer

- `lib/data/repositories/` contains persistence and remote-fetch repositories
- `lib/data/services/` contains device/platform services
- `lib/data/memory/` contains in-memory stores
- `lib/data/reference/` contains static app mappings and reference values
- `ProfileRepository` stores the full `UserProfile`
- `RoutineRepository` stores the routine locally
- `ExerciseApiRepository` handles remote exercise search
- `LocationService` handles GPS access, permission flow, and distance calculations
- `ApiExercise` models the exercise API response

### Domain Layer

- provider classes now live under `lib/domain/providers/`
- `ProfileProvider` manages user profile state
- `RoutineProvider` manages routine state
- `ExerciseSearchProvider` manages API search state
- `WorkoutTrackingProvider` manages workout lifecycle, timers, route polling, and outdoor workout history

### Presentation Layer

- screens and widgets live under `lib/presentation/`
- navigation is centralized in `lib/presentation/navigation/app_router.dart`
- UI consumes provider state and does not access persistence directly

## Project Structure

```text
lib/
|-- main.dart
|-- verify_architecture.dart
|-- data/
|   |-- models/
|   |   |-- api_exercise.dart
|   |-- memory/
|   |   |-- category_session_store.dart
|   |   |-- custom_exercise_store.dart
|   |-- reference/
|   |   |-- exercise_category_data.dart
|   |   |-- met_values.dart
|   |-- repositories/
|   |   |-- exercise_api_repository.dart
|   |   |-- profile_repository.dart
|   |   |-- routine_repository.dart
|   |-- services/
|   |   |-- location_service.dart
|-- domain/
|   |-- providers/
|   |   |-- exercise_search_provider.dart
|   |   |-- profile_provider.dart
|   |   |-- routine_provider.dart
|   |   |-- workout_tracking_provider.dart
|-- models/
|   |-- category_session.dart
|   |-- custom_exercise.dart
|   |-- exercise.dart
|   |-- outdoor_workout_record.dart
|   |-- progress_stats.dart
|   |-- user_profile.dart
|   |-- workout_category.dart
|-- presentation/
|   |-- navigation/
|   |   |-- app_router.dart
|   |-- screens/
|   |   |-- add_exercise_screen.dart
|   |   |-- assessment_screen.dart
|   |   |-- bmi_calculator_screen.dart
|   |   |-- exercise_browse_screen.dart
|   |   |-- exercise_detail_screen.dart
|   |   |-- exercise_list_screen.dart
|   |   |-- exercise_search_screen.dart
|   |   |-- home_screen.dart
|   |   |-- outdoor_workout_history_screen.dart
|   |   |-- outdoor_workout_screen.dart
|   |   |-- routine_summary_screen.dart
|   |-- widgets/
|   |   |-- app_drawer.dart
|   |   |-- bmi_calculate_button.dart
|   |   |-- bmi_input_card.dart
|   |   |-- bmi_result_card.dart
|   |   |-- category_tile.dart
|   |   |-- home_banner.dart
|-- utils/
|   |-- bmi_calculator.dart
|   |-- calorie_calculator.dart
|   |-- fat_loss_calculator.dart
```

## Main Files

- `lib/data/repositories/exercise_api_repository.dart`
- `lib/data/services/location_service.dart`
- `lib/domain/providers/exercise_search_provider.dart`
- `lib/domain/providers/workout_tracking_provider.dart`
- `lib/models/exercise.dart`
- `lib/models/outdoor_workout_record.dart`
- `lib/presentation/navigation/app_router.dart`
- `lib/presentation/screens/home_screen.dart`
- `lib/presentation/screens/exercise_search_screen.dart`
- `lib/presentation/screens/exercise_list_screen.dart`
- `lib/presentation/screens/outdoor_workout_screen.dart`
- `lib/presentation/screens/outdoor_workout_history_screen.dart`

## Getting Started

1. Install Flutter.
2. Run `flutter pub get`.
3. Run `flutter run`.

## API Search Setup

The live search feature uses API Ninjas.

1. Create an API Ninjas account.
2. Generate an API key.
3. Add your key in `lib/data/repositories/exercise_api_repository.dart`.
4. Run the app and open `Search API Exercises`.

Note:

- avoid committing real API keys
- prefer environment or config-based secrets for production work

## Outdoor Workout Setup

The outdoor workout feature uses `geolocator` and platform location permissions.

Android:

- `android/app/src/main/AndroidManifest.xml`
  - `ACCESS_FINE_LOCATION`
  - `ACCESS_COARSE_LOCATION`

iOS:

- `ios/Runner/Info.plist`
  - `NSLocationWhenInUseUsageDescription`

The permission request is intentionally triggered only when the user taps `Start Run`.

## Verify Architecture

Run:

```bash
dart lib/verify_architecture.dart
```

The script checks:

- `lib/presentation/` has no `shared_preferences` imports
- `lib/data/` has no `ChangeNotifier` usage
- `lib/domain/` has no `shared_preferences` imports outside intended provider logic

## Dependencies

- `dio`
- `geolocator`
- `provider`
- `shared_preferences`
- `url_launcher`

## Recent Commit Groups

Recent work was split into focused commits:

- `Add location permissions and plugin dependencies`
- `Add three gate geolocator location service`
- `Add workout tracking provider lifecycle state`
- `Add outdoor workout screens and navigation`
- `Add automatic route polling workout tracking`
- `Refactor workout categories to use API types`
- `Show API exercise metadata in detail views`
- `Remove obsolete static category screen flow`
