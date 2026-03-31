# FitnessApp

A Flutter fitness tracker organized into layered architecture with models, repositories, injected providers, and a presentation layer. The app now includes live exercise search through the API Ninjas Exercises API in addition to its local routine and profile flows.

## Overview

The app lets users browse workouts, build a routine, search live exercise data, manage profile settings, and save local data across app restarts. The codebase is organized so that:

- `models` define typed app data
- `data` handles persistence
- `domain` manages state and business logic
- `presentation` contains screens, widgets, and navigation
- `main.dart` wires everything together with dependency injection

## Features

- Dashboard with `Strength`, `HIIT`, `Cardio`, `Flexibility`, `Weightlifting`, and `Strongman` workout categories
- Custom exercise creation with validation and live volume preview
- Shared routine flow backed by `provider`
- Profile management with typed `UserProfile` data
- Local persistence with `shared_preferences`
- JSON-based profile and routine storage through repositories
- Live exercise search powered by `dio` and API Ninjas
- Cascading API filters for exercise `type` and optional `muscle`
- Expandable API result cards with equipment, instructions, and safety info
- Add-to-routine actions from API search results
- Visual thumbnails for API exercise results
- Assessment and preference management screens
- Architecture verification script for import-rule checks

## Architecture

### Data Layer

- `ProfileRepository` stores the full `UserProfile` as one JSON string
- `RoutineRepository` stores the routine as one JSON string
- `ExerciseApiRepository` handles remote exercise search through `dio`
- `ApiExercise` models the remote API response shape under `lib/data/models/`
- Repositories are the only classes that know about `shared_preferences`

### Domain Layer

- `ProfileProvider` receives `ProfileRepository` through its constructor
- `RoutineProvider` receives `RoutineRepository` through its constructor
- `ExerciseSearchProvider` receives `ExerciseApiRepository` and manages loading, results, retry, and error state
- Providers expose reactive state to the UI with `ChangeNotifier`

### Presentation Layer

- Screens, widgets, and router files live under `lib/presentation/`
- Presentation files depend on `models` and `domain`
- Presentation files do not access persistence directly

## Project Structure

- `lib/main.dart` - app entry point and dependency wiring
- `lib/models/` - typed data models such as `UserProfile` and `Exercise`
- `lib/data/` - repositories and static/local data sources
- `lib/data/models/` - remote API response models
- `lib/domain/` - injected providers and state logic
- `lib/presentation/` - router, screens, widgets, and home tab
- `lib/utils/` - helper calculators
- `lib/verify_architecture.dart` - architecture rule verification script

```text
lib/
|-- main.dart
|-- verify_architecture.dart
|-- data/
|   |-- category_data.dart
|   |-- category_session_store.dart
|   |-- custom_exercise_store.dart
|   |-- exercise_api_repository.dart
|   |-- met_values.dart
|   |-- models/
|   |   |-- api_exercise.dart
|   |-- profile_repository.dart
|   |-- routine_repository.dart
|-- domain/
|   |-- exercise_search_provider.dart
|   |-- profile_provider.dart
|   |-- routine_provider.dart
|-- models/
|   |-- category_session.dart
|   |-- custom_exercise.dart
|   |-- exercise.dart
|   |-- progress_stats.dart
|   |-- user_profile.dart
|   |-- workout_category.dart
|-- presentation/
|   |-- app_router.dart
|   |-- screens/
|   |   |-- add_exercise_screen.dart
|   |   |-- assessment_screen.dart
|   |   |-- base_category_screen.dart
|   |   |-- bmi_calculator_screen.dart
|   |   |-- cardio_screen.dart
|   |   |-- exercise_browse_screen.dart
|   |   |-- exercise_detail_screen.dart
|   |   |-- exercise_list_screen.dart
|   |   |-- exercise_search_screen.dart
|   |   |-- flexibility_screen.dart
|   |   |-- hiit_screen.dart
|   |   |-- routine_summary_screen.dart
|   |   |-- strength_screen.dart
|   |-- tabs/
|   |   |-- homescreen.dart
|   |-- widgets/
|   |   |-- app_drawer.dart
|   |   |-- banner.dart
|   |   |-- bmi_calculate_button.dart
|   |   |-- bmi_input_card.dart
|   |   |-- bmi_result_card.dart
|   |   |-- category_banner.dart
|   |   |-- category_tile.dart
|   |   |-- home_banner.dart
|   |   |-- metric_card.dart
|   |   |-- profile_completeness.dart
|   |   |-- quick_stats.dart
|   |   |-- tiles.dart
|-- utils/
|   |-- bmi_calculator.dart
|   |-- calorie_calculator.dart
|   |-- fat_loss_calculator.dart
```

## Main Files

- `lib/models/user_profile.dart`
- `lib/models/exercise.dart`
- `lib/data/models/api_exercise.dart`
- `lib/data/exercise_api_repository.dart`
- `lib/data/profile_repository.dart`
- `lib/data/routine_repository.dart`
- `lib/domain/exercise_search_provider.dart`
- `lib/domain/profile_provider.dart`
- `lib/domain/routine_provider.dart`
- `lib/presentation/app_router.dart`
- `lib/presentation/screens/exercise_search_screen.dart`
- `lib/presentation/tabs/homescreen.dart`

## Getting Started

1. Install Flutter.
2. Run `flutter pub get`.
3. Run `flutter run`.

## API Search Setup

The live search feature uses API Ninjas.

1. Create an API Ninjas account.
2. Generate an API key.
3. Add your key in `lib/data/exercise_api_repository.dart`.
4. Run the app and open `Search API Exercises` from the dashboard or drawer.

Note:

- Keep the tracked code on a placeholder such as `YOUR_KEY_HERE`.
- Avoid committing real API keys to git history.

## Verify Architecture

Run:

```bash
dart lib/verify_architecture.dart
```

The script checks:

- `lib/presentation/` has no `shared_preferences` imports
- `lib/data/` has no `ChangeNotifier` usage
- `lib/domain/` has no `shared_preferences` imports

## Dependencies

- `dio`
- `provider`
- `shared_preferences`

## Commit History

Recent feature work was split into focused commits:

- `Add Dio dependency for API integration`
- `Add API exercise model parsing`
- `Add exercise API repository with Dio`
- `Add exercise search provider state`
- `Add exercise search screen and routing`
- `Add weightlifting and strongman categories`
- `Add API routine actions to search results`
- `Add visual thumbnails to API search results`
- `Add new categories to exercise browser`
- `Add cascading type and muscle filters`
