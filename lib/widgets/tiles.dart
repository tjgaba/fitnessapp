import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const CategoryTile({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        // 🔥 Neon glow effect
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 25,
            spreadRadius: 5,
          ),
        ],

        border: Border.all(
          color: color,
          width: 1.5,
        ),
      ),

      child: Stack(
        children: [
          // 🔹 TOP ICON
          Positioned(
            top: 12,
            left: 12,
            child: Icon(icon, color: color, size: 26),
          ),

          // 🔹 FAVORITE ICON
          const Positioned(
            top: 12,
            right: 12,
            child: Icon(Icons.favorite_border, color: Colors.grey),
          ),

          // 🔹 CENTER CONTENT
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Start training",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}