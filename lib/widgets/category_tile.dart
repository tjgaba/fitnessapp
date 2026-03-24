import 'package:flutter/material.dart';
import '../app_router.dart';
import '../models/workout_category.dart';

/// Tappable tile for a workout category.
/// Uses InkWell for ripple feedback and navigates to the matching screen.
class CategoryTile extends StatefulWidget {
  final WorkoutCategory category;

  const CategoryTile({super.key, required this.category});

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  bool _pressed = false;

  void _handleTap() {
    setState(() => _pressed = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _pressed = false);
    });

    Navigator.of(context).pushRouteWithArgs(
      AppRoute.exerciseList,
      ExerciseListArgs(
        categoryName: widget.category.title,
        themeColor: widget.category.color,
        iconData: widget.category.icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.category.color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: _pressed ? 0.65 : 0.35),
                blurRadius: _pressed ? 22 : 12,
                spreadRadius: _pressed ? 3 : 1,
              ),
            ],
            border: Border.all(
              color: color.withValues(alpha: _pressed ? 1.0 : 0.6),
              width: _pressed ? 2.5 : 1.5,
            ),
          ),
          child: Stack(
            children: [
              // Background accent circle
              Positioned(
                bottom: -20,
                right: -20,
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Icon — top left
              Positioned(
                top: 12,
                left: 12,
                child: Icon(widget.category.icon, color: color, size: 26),
              ),

              // Arrow — top right
              Positioned(
                top: 14,
                right: 12,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color.withValues(alpha: 0.5),
                  size: 13,
                ),
              ),

              // Centre label
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(widget.category.icon, color: color, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          widget.category.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: color,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap to train',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black.withValues(alpha: 0.38),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
