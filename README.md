# FitnessApp

A Flutter fitness and workout tracker focused on category-based exercise discovery, custom exercise creation, and Provider-powered routine building.

## Overview

This project now includes a global routine workflow built with the `provider` package and `ChangeNotifier`. Users can browse exercises, add them to a shared daily routine, review aggregate training stats, and remove or clear items while the UI stays synchronized across screens.

## Current Features

- Responsive dashboard with workout categories for `Strength`, `HIIT`, `Cardio`, and `Flexibility`
- Type-safe navigation through `app_router.dart`
- Custom exercise creation with validation and live volume preview
- Provider-based routine state shared across the app
- Categorized exercise browser with expand/minimize sections
- Routine summary screen with:
  - total exercise count
  - total sets
  - total volume
  - muscle-group balance bars
  - grouped exercise sections with expand/minimize controls
- Reactive add/remove routine actions from:
  - exercise browser
  - exercise list screens
  - exercise detail screen
- **Profile and Preferences System** with local persistence using `shared_preferences`:
  - User profile: name, age, gender, height, weight, target weight, activity level, heart rate, goal
  - App preferences: weight unit (kg/lbs), rest timer, notifications
  - Data is validated and survives app restarts
  - Profile and preferences are managed via `ProfileProvider`
  - Selective data wipe: reset only profile or all settings, with confirmation dialogs
  - Dashboard greeting and goal chip update in real time
  - Profile and preferences UI in the settings/profile screen
  - All changes are persisted and reflected immediately in the UI

## State Management

Routine state is managed with:

- `provider`
- `ChangeNotifier`
- `context.watch<RoutineProvider>()`
- `context.read<RoutineProvider>()`

The shared routine data lives in `RoutineProvider`, including derived values such as `totalSets`, `totalVolume`, and `muscleGroupBreakdown`.

## Main Screens

- `HomeScreen`: dashboard, quick access to browse and summary flows, custom exercise section, dynamic greeting
- `ExerciseBrowseScreen`: full exercise catalog plus user-created exercises, grouped by category
- `ExerciseListScreen`: category-specific exercise listing with routine add/remove actions
- `ExerciseDetailScreen`: detailed exercise view with routine add/remove action
- `RoutineSummaryScreen`: provider-backed summary, totals, balance bars, grouped routine display
- `AddExerciseScreen`: form for creating validated custom exercises
- `AssessmentScreen`: profile and assessment workflow
- `Settings/Profile Screen`: edit profile and preferences, reset data, all changes persisted

## Project Structure

- `lib/main.dart` - app entry point and provider injection
- `lib/app_router.dart` - typed route definitions and navigation helpers
- `lib/models/exercise.dart` - immutable routine exercise model
- `lib/models/custom_exercise.dart` - custom exercise data model
- `lib/models/user_profile.dart` - user profile data model
- `lib/providers/routine_provider.dart` - global routine state and derived getters
- `lib/providers/profile_provider.dart` - profile and preferences state, persistence, and validation
- `lib/screens/` - app screens including browse, detail, summary, assessment, settings/profile, and forms
- `lib/data/` - category data and local custom exercise store
- `lib/widgets/` - reusable UI building blocks
- `lib/tabs/homescreen.dart` - main dashboard tab

## Getting Started

1. Install Flutter from [flutter.dev](https://flutter.dev/docs/get-started/install).
2. Run `flutter pub get`.
3. Run `flutter run`.

## Provider Routine Flow

1. Open `Browse Exercises` or any category exercise screen.
2. Add exercises to the routine.
3. Open `Routine Summary`.
4. Review totals, muscle-group balance bars, and grouped exercises.
5. Remove items or clear the routine and watch the rest of the UI update automatically.

## Requirements

- Flutter SDK `^3.11.1`
- Dart SDK matching the Flutter version in `pubspec.yaml`
- `provider` for state management
- `shared_preferences` for local data persistence

## Notes

- The routine and profile features use provider as the single source of truth for shared data.
- Local UI expand/minimize controls use widget-local state only.
- Profile and preferences are loaded and validated on startup.
- All profile and preference changes are persisted and reflected immediately in the UI.
- Selective reset options allow users to wipe only profile or all settings, with confirmation.
