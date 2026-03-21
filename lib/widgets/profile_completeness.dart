import 'package:flutter/material.dart';

/// A labelled progress bar showing how complete the user's profile is.
class ProfileCompleteness extends StatelessWidget {
  final double value; // 0.0 – 1.0

  const ProfileCompleteness({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    const color = Colors.blueAccent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Profile Completeness',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: color.withOpacity(0.15),
            valueColor: const AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
