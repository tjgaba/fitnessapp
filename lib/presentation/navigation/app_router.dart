import 'package:flutter/material.dart';

import '../../models/exercise.dart';
import '../screens/add_exercise_screen.dart';
import '../screens/assessment_screen.dart';
import '../screens/bmi_calculator_screen.dart';
import '../screens/exercise_browse_screen.dart';
import '../screens/exercise_detail_screen.dart';
import '../screens/exercise_list_screen.dart';
import '../screens/exercise_search_screen.dart';
import '../screens/home_screen.dart';
import '../screens/outdoor_workout_history_screen.dart';
import '../screens/outdoor_workout_screen.dart';
import '../screens/routine_summary_screen.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    // Centralized entry point for future onboarding/auth/startup decisions.
    const initialRoute = AppRoute.home;
    return initialRoute.buildPage();
  }
}

class ExerciseListArgs {
  final String categoryName;
  final Color themeColor;
  final IconData iconData;

  const ExerciseListArgs({
    required this.categoryName,
    required this.themeColor,
    required this.iconData,
  });
}

class ExerciseDetailArgs {
  final Exercise exercise;
  final Color accentColor;

  const ExerciseDetailArgs({
    required this.exercise,
    required this.accentColor,
  });
}

enum AppRoute<T> {
  home<void>('/home'),
  exerciseList<ExerciseListArgs>('/exercise-list'),
  exerciseDetail<ExerciseDetailArgs>('/exercise-detail'),
  exerciseBrowse<void>('/exercise-browse'),
  exerciseSearch<void>('/exercise-search'),
  outdoorWorkout<void>('/outdoor-workout'),
  outdoorWorkoutHistory<void>('/outdoor-workout-history'),
  routineSummary<void>('/routine-summary'),
  addExercise<void>('/add-exercise'),
  bmi<void>('/bmi'),
  assessment<void>('/assessment');

  const AppRoute(this.name);

  final String name;

  Widget buildPage([T? args]) {
    switch (this) {
      case AppRoute.home:
        return const HomeScreen();

      case AppRoute.exerciseList:
        final typedArgs = args as ExerciseListArgs;
        return ExerciseListScreen(
          categoryName: typedArgs.categoryName,
          themeColor: typedArgs.themeColor,
          iconData: typedArgs.iconData,
        );

      case AppRoute.exerciseDetail:
        final typedArgs = args as ExerciseDetailArgs;
        return ExerciseDetailScreen(
          exercise: typedArgs.exercise,
          accentColor: typedArgs.accentColor,
        );

      case AppRoute.exerciseBrowse:
        return const ExerciseBrowseScreen();

      case AppRoute.exerciseSearch:
        return const ExerciseSearchScreen();

      case AppRoute.outdoorWorkout:
        return const OutdoorWorkoutScreen();

      case AppRoute.outdoorWorkoutHistory:
        return const OutdoorWorkoutHistoryScreen();

      case AppRoute.routineSummary:
        return const RoutineSummaryScreen();

      case AppRoute.addExercise:
        return const AddExerciseScreen();

      case AppRoute.bmi:
        return const BmiCalculatorScreen();

      case AppRoute.assessment:
        return const AssessmentScreen();
    }
  }

  MaterialPageRoute<dynamic> route([T? args]) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => buildPage(args),
      settings: RouteSettings(name: name),
    );
  }
}

extension NavigatorExtension on NavigatorState {
  Future<dynamic> pushRoute(AppRoute<void> route) {
    return push<dynamic>(route.route());
  }

  Future<dynamic> pushRouteWithArgs<T>(AppRoute<T> route, T args) {
    return push<dynamic>(route.route(args));
  }
}



