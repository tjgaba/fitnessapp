import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/providers/auth_provider.dart';
import '../navigation/app_router.dart';
import '../utils/auth_prompt.dart';
import '../../data/reference/exercise_category_data.dart';
import '../../models/workout_category.dart';

class AppDrawer extends StatelessWidget {
  final String? currentRouteName;
  final String? currentCategoryName;

  const AppDrawer({
    super.key,
    this.currentRouteName,
    this.currentCategoryName,
  });

  @override
  Widget build(BuildContext context) {
    final isSignedIn = context.watch<AuthProvider>().isSignedIn;

    return Drawer(
      backgroundColor: const Color(0xFFF5F7FB),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEFF6FF), Color(0xFFF0FDF4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.blueAccent.withValues(alpha: 0.18),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: Colors.blueAccent,
                    size: 28,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Fitness Navigation',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Move between the dashboard, tools, and training categories from one place.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _DrawerItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    color: Colors.blueAccent,
                    selected: currentRouteName == AppRoute.home.name,
                    onTap: () => _openRootRoute(context, AppRoute.home),
                  ),
                  _DrawerItem(
                    icon: Icons.playlist_add_circle_outlined,
                    label: 'Exercise Browser',
                    color: Colors.teal,
                    selected: currentRouteName == AppRoute.exerciseBrowse.name,
                    enabled: isSignedIn,
                    onTap: () => _openRoute(context, AppRoute.exerciseBrowse),
                  ),
                  _DrawerItem(
                    icon: Icons.travel_explore_outlined,
                    label: 'Search API Exercises',
                    color: Colors.blueAccent,
                    selected: currentRouteName == AppRoute.exerciseSearch.name,
                    enabled: isSignedIn,
                    onTap: () => _openRoute(context, AppRoute.exerciseSearch),
                  ),
                  _DrawerItem(
                    icon: Icons.route_rounded,
                    label: 'Outdoor Workout',
                    color: Colors.deepOrange,
                    selected: currentRouteName == AppRoute.outdoorWorkout.name,
                    enabled: isSignedIn,
                    onTap: () => _openRoute(context, AppRoute.outdoorWorkout),
                  ),
                  _DrawerItem(
                    icon: Icons.history_rounded,
                    label: 'Outdoor History',
                    color: Colors.deepOrange,
                    selected:
                        currentRouteName == AppRoute.outdoorWorkoutHistory.name,
                    enabled: isSignedIn,
                    onTap: () =>
                        _openRoute(context, AppRoute.outdoorWorkoutHistory),
                  ),
                  _DrawerItem(
                    icon: Icons.fact_check_outlined,
                    label: 'Routine Summary',
                    color: Colors.indigo,
                    selected: currentRouteName == AppRoute.routineSummary.name,
                    enabled: isSignedIn,
                    onTap: () => _openRoute(context, AppRoute.routineSummary),
                  ),
                  _DrawerItem(
                    icon: Icons.add_circle_outline,
                    label: 'Add Exercise',
                    color: Colors.green,
                    selected: currentRouteName == AppRoute.addExercise.name,
                    enabled: isSignedIn,
                    onTap: () => _openRoute(context, AppRoute.addExercise),
                  ),
                  _DrawerItem(
                    icon: Icons.monitor_weight_outlined,
                    label: 'BMI Calculator',
                    color: Colors.orange,
                    selected: currentRouteName == AppRoute.bmi.name,
                    enabled: isSignedIn,
                    onTap: () => _openRoute(context, AppRoute.bmi),
                  ),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'Profile Settings',
                    color: Colors.purple,
                    selected: currentRouteName == AppRoute.assessment.name,
                    enabled: isSignedIn,
                    onTap: () => _openRoute(context, AppRoute.assessment),
                  ),
                  _DrawerItem(
                    icon: isSignedIn ? Icons.verified_user_outlined : Icons.login_rounded,
                    label: isSignedIn ? 'Signed In' : 'Sign In',
                    color: Colors.black87,
                    selected: false,
                    onTap: () {
                      Navigator.of(context).pop();
                      if (!isSignedIn) {
                        openLoginScreen(context);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...appCategories.map(
                    (category) => _DrawerItem(
                      icon: category.icon,
                      label: category.title,
                      color: category.color,
                      selected: currentRouteName == AppRoute.exerciseList.name &&
                          currentCategoryName == category.title,
                      onTap: () => _openCategory(context, category),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openRootRoute(BuildContext context, AppRoute<void> route) {
    Navigator.of(context).pop();
    if (currentRouteName == route.name) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      route.route(),
      (existingRoute) => false,
    );
  }

  void _openRoute(BuildContext context, AppRoute<void> route) {
    Navigator.of(context).pop();
    if (currentRouteName == route.name) {
      return;
    }
    Navigator.of(context).push(route.route());
  }

  void _openCategory(BuildContext context, WorkoutCategory category) {
    Navigator.of(context).pop();
    final route = AppRoute.exerciseList.route(
      ExerciseListArgs(
        categoryName: category.title,
        themeColor: category.color,
        iconData: category.icon,
      ),
    );

    if (currentRouteName == AppRoute.exerciseList.name &&
        currentCategoryName == category.title) {
      return;
    }

    Navigator.of(context).push(route);
  }
}

class DrawerBackAction extends StatelessWidget {
  const DrawerBackAction({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Navigator.of(context).canPop()) {
      return const SizedBox.shrink();
    }

    return IconButton(
      tooltip: 'Go Back',
      onPressed: () => Navigator.of(context).maybePop(),
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.selected,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: enabled ? onTap : () => showSignInRequiredDialog(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? color.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? color.withValues(alpha: 0.55)
                    : color.withValues(alpha: enabled ? 0.18 : 0.08),
                width: selected ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(
                    alpha: selected ? 0.18 : enabled ? 0.08 : 0.03,
                  ),
                  blurRadius: selected ? 10 : 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: enabled ? 0.1 : 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: enabled ? color : color.withValues(alpha: 0.45),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: enabled
                          ? (selected ? color : Colors.black87)
                          : Colors.black45,
                      fontSize: 14,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: color.withValues(alpha: enabled ? 0.65 : 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


