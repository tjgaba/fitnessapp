import 'package:flutter/material.dart';

class BmiResultCard extends StatelessWidget {
  final double? bmi;
  final String? category;
  final Color color;

  const BmiResultCard({
    super.key,
    required this.bmi,
    required this.category,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final hasResult = bmi != null && category != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.28), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.16),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: hasResult
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your BMI Result',
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        bmi!.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        category!,
                        style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _messageForCategory(category!),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Result Preview',
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Enter your height and weight, then tap Calculate BMI to show your result and category.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
    );
  }

  String _messageForCategory(String category) {
    switch (category) {
      case 'Underweight':
        return 'Your BMI falls below the recommended range. A balanced nutrition plan and progressive strength work may help.';
      case 'Normal':
        return 'Your BMI is in the recommended range. Focus on consistency and overall fitness maintenance.';
      case 'Overweight':
        return 'Your BMI is above the recommended range. Cardio, strength training, and nutrition consistency can help.';
      case 'Obese':
        return 'Your BMI is in the highest range. Start gradually and consider professional guidance alongside exercise.';
      default:
        return '';
    }
  }
}


