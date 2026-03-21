import 'package:flutter/material.dart';
import '../models/workout_category.dart';
import '../widgets/category_banner.dart';

/// Shared layout used by all four category screens.
class BaseCategoryScreen extends StatelessWidget {
  final WorkoutCategory category;

  const BaseCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final color = category.color;
    final done = category.sessionsCompleted;
    final goal = category.sessionsGoalPerWeek;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        foregroundColor: Colors.black87,
        title: Row(
          children: [
            Icon(category.icon, color: color, size: 22),
            const SizedBox(width: 8),
            Text(
              category.title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category-specific banner
            CategoryBanner(category: category),

            // Description
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: color.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                      color: color.withOpacity(0.12),
                      blurRadius: 8,
                      spreadRadius: 1),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: color, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _description(category.title),
                      style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),

            // Sessions list header
            _sectionTitle('This Week\'s Sessions', color),
            const SizedBox(height: 10),

            ...List.generate(done, (i) => _SessionRow(
                  index: i + 1,
                  color: color,
                  title: category.title,
                  completed: true,
                )),
            ...List.generate(goal - done, (i) => _SessionRow(
                  index: done + i + 1,
                  color: color,
                  title: category.title,
                  completed: false,
                )),

            const SizedBox(height: 20),

            // Start Workout button
            _GlowButton(
              label: 'START WORKOUT',
              color: color,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${category.title} workout coming soon!'),
                  backgroundColor: color.withOpacity(0.85),
                  behavior: SnackBarBehavior.floating,
                ));
              },
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  String _description(String title) {
    switch (title) {
      case 'HIIT':
        return 'High-intensity interval training burns maximum calories in short bursts of effort.';
      case 'Strength':
        return 'Resistance training builds muscle mass and increases your resting metabolic rate.';
      case 'Cardio':
        return 'Steady-state cardio improves cardiovascular health and builds endurance over time.';
      case 'Flexibility':
        return 'Stretching and mobility work improve range of motion, posture, and recovery speed.';
      default:
        return '';
    }
  }

  Widget _sectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4)),
      ],
    );
  }
}

// ── Session row ───────────────────────────────────────────────────────────────

class _SessionRow extends StatelessWidget {
  final int index;
  final Color color;
  final String title;
  final bool completed;

  const _SessionRow({
    required this.index,
    required this.color,
    required this.title,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: completed ? color.withOpacity(0.45) : Colors.black12,
          width: 1,
        ),
        boxShadow: completed
            ? [
                BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 6,
                    spreadRadius: 1)
              ]
            : [],
      ),
      child: Row(
        children: [
          Icon(
            completed
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: completed ? color : Colors.black26,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$title – Session $index',
              style: TextStyle(
                color: completed ? Colors.black87 : Colors.black45,
                fontSize: 13,
                fontWeight:
                    completed ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          if (!completed)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: color.withOpacity(0.45), width: 1),
                boxShadow: [
                  BoxShadow(
                      color: color.withOpacity(0.18), blurRadius: 5)
                ],
              ),
              child: Text('Start',
                  style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}

// ── Glow button ───────────────────────────────────────────────────────────────

class _GlowButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _GlowButton(
      {required this.label, required this.color, required this.onTap});

  @override
  State<_GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<_GlowButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() => _pressed = true);
          Future.delayed(const Duration(milliseconds: 150), () {
            if (mounted) setState(() => _pressed = false);
          });
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.color, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: widget.color
                    .withOpacity(_pressed ? 0.55 : 0.28),
                blurRadius: _pressed ? 20 : 10,
              ),
            ],
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.color,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
