import 'package:flutter/material.dart';
import '../screens/assessment_screen.dart';
import 'metric_card.dart';

/// Home screen overall-stats banner.
/// Light background with neon-glow styling — no dark theme.
class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  bool _profilePressed = false;

  // Mock overall stats (will come from real data layer later)
  final double _bmi = 24.5;
  final String _bmiLabel = 'Normal';
  final int _totalSteps = 12543;
  final int _totalCalories = 1840;
  final double _estimatedFatLoss = 0.24;
  final String _totalExerciseTime = '3h 20m';

  void _openProfile() {
    setState(() => _profilePressed = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _profilePressed = false);
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AssessmentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.blueAccent.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 
              _profilePressed ? 0.45 : 0.2,
            ),
            blurRadius: _profilePressed ? 28 : 16,
            spreadRadius: _profilePressed ? 4 : 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Stats',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.4,
                ),
              ),
              // View Profile button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _openProfile,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.blueAccent, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withValues(alpha: 
                              _profilePressed ? 0.55 : 0.22),
                          blurRadius: _profilePressed ? 14 : 7,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_outline,
                            color: Colors.blueAccent, size: 14),
                        SizedBox(width: 5),
                        Text(
                          'View Profile',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Stats row 1: BMI · Steps · Calories
          Row(
            children: [
              MetricCard(
                label: 'BMI',
                value: _bmi.toStringAsFixed(1),
                sub: _bmiLabel,
                color: Colors.blueAccent,
              ),
              const SizedBox(width: 8),
              MetricCard(
                label: 'Steps',
                value: _totalSteps.toString(),
                sub: 'today',
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              MetricCard(
                label: 'Calories',
                value: '$_totalCalories kcal',
                sub: 'total',
                color: Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Stats row 2: Fat Loss · Exercise Time
          Row(
            children: [
              MetricCard(
                label: 'Est. Fat Loss',
                value: '~$_estimatedFatLoss kg',
                sub: 'this week',
                color: Colors.pinkAccent,
              ),
              const SizedBox(width: 8),
              MetricCard(
                label: 'Exercise Time',
                value: _totalExerciseTime,
                sub: 'completed',
                color: Colors.purple,
              ),
              const SizedBox(width: 8),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}