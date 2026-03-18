# FitnessApp

A modern, responsive Flutter app for tracking and exploring workout routines. This app features a visually appealing dashboard, interactive workout categories, and a daily featured workout banner.

## Features

- **Responsive Dashboard:**
  - Adaptive grid layout for workout categories (2 columns on mobile, 3 on tablet, 4 on desktop).
- **Custom Workout Tiles:**
  - Material 3 styled tiles for each workout category (Cardio, Strength, Flexibility, HIIT), built with Container and BoxDecoration for custom look and feel.
- **Compositional Layout:**
  - Uses Row, Column, and Stack widgets for flexible and clean UI composition.
- **Interactive Favorites:**
  - Each workout tile includes a heart icon that toggles between outlined and filled when tapped, allowing users to mark favorites.
- **Featured Workout Banner:**
  - A prominent banner at the top highlights the "Workout of the Day" with a title, description, and a Start button.
- **Material 3 Design:**
  - The app uses Material 3 theming for a modern, cohesive appearance.

## Screenshots

<!-- Optionally add screenshots here -->

## Getting Started

1. Ensure you have (https://flutter.dev/docs/get-started/install) installed.
2. Run `flutter pub get` to fetch dependencies.
3. Run `flutter run` to launch the app on your device or emulator.

## Project Structure

- `lib/main.dart` — App entry point and theme setup
- `lib/tabs/homescreen.dart` — Main dashboard screen
- `lib/widgets/tiles.dart` — Custom workout category tiles
- `lib/widgets/banner.dart` — Featured workout banner widget

## Requirements

- Flutter 3.11.1 or higher

