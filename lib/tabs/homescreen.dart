import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // 🔥 RESPONSIVE LOGIC
  int getCrossAxisCount(double width) {
    if (width >= 1024) return 4; // large screens
    if (width >= 600) return 3;  // tablets
    return 2;                    // phones
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fitness Dashboard"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: 6, // placeholder items

          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: getCrossAxisCount(width),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),

          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  "Workout $index",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}