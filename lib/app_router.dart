import 'package:flutter/material.dart';

import 'screens/add_exercise_screen.dart';
import 'screens/assessment_screen.dart';
import 'screens/bmi_calculator_screen.dart';
import 'screens/exercise_detail_screen.dart';
import 'screens/exercise_list_screen.dart';
import 'tabs/homescreen.dart';

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
  final String exerciseName;
  final String muscleGroup;
  final int sets;
  final int reps;
  final double weight;

  const ExerciseDetailArgs({
    required this.exerciseName,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    required this.weight,
  });
}

enum AppRoute<T> {
  home<void>('/home'),
  exerciseList<ExerciseListArgs>('/exercise-list'),
  exerciseDetail<ExerciseDetailArgs>('/exercise-detail'),
  addExercise<void>('/add-exercise'),
  bmi<void>('/bmi'),
  assessment<void>('/assessment');

  const AppRoute(this.name);

  final String name;

  MaterialPageRoute<dynamic> route([T? args]) {
    switch (this) {
      case AppRoute.home:      
        return MaterialPageRoute<dynamic>(
          builder: (_) => const HomeScreen(),
          settings: RouteSettings(name: name),
        );

      case AppRoute.exerciseList:
        final typedArgs = args as ExerciseListArgs;
        return MaterialPageRoute<dynamic>(
          builder: (_) => ExerciseListScreen(
            categoryName: typedArgs.categoryName,
            themeColor: typedArgs.themeColor,
            iconData: typedArgs.iconData,
          ),

          settings: RouteSettings(name: name),
        );

      case AppRoute.exerciseDetail:
        final typedArgs = args as ExerciseDetailArgs;
        return MaterialPageRoute<dynamic>(
          builder: (_) => ExerciseDetailScreen(
            exerciseName: typedArgs.exerciseName,
            muscleGroup: typedArgs.muscleGroup,
            sets: typedArgs.sets,
            reps: typedArgs.reps,
            weight: typedArgs.weight,
          ),
          settings: RouteSettings(name: name),
        );

      case AppRoute.addExercise:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const AddExerciseScreen(),
          settings: RouteSettings(name: name),
        );

      case AppRoute.bmi:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const BmiCalculatorScreen(),
          settings: RouteSettings(name: name),
        );
        
      case AppRoute.assessment:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const AssessmentScreen(),
          settings: RouteSettings(name: name),
        );
    }
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
