import 'package:flutter/material.dart';
import '../widgets/tiles.dart';
import '../widgets/banner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  int getCrossAxisCount(double width) {
    if (width >= 1024) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final categories = [
      {"title": "Cardio", "icon": Icons.directions_run, "color": Colors.pinkAccent},
      {"title": "Strength", "icon": Icons.fitness_center, "color": Colors.blueAccent},
      {"title": "Flexibility", "icon": Icons.self_improvement, "color": Colors.greenAccent},
      {"title": "HIIT", "icon": Icons.flash_on, "color": Colors.orangeAccent},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fitness Dashboard"),
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const FeaturedBanner(),
            Expanded(
              child: GridView.builder(
          itemCount: categories.length,

          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: getCrossAxisCount(width),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),

          itemBuilder: (context, index) {
            final item = categories[index];

            return CategoryTile(
              title: item["title"] as String,
              icon: item["icon"] as IconData,
              color: item["color"] as Color,
            );
          },
        ),
            ),
          ],
        ),
      ),
    );
  }
}