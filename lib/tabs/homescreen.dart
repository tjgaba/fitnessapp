import 'package:flutter/material.dart';

import '../widgets/category_tile.dart';
import '../widgets/home_banner.dart';
import '../data/category_data.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        title: const Text('Fitness Dashboard'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Open BMI Calculator',
              onPressed: () => Navigator.pushNamed(context, '/bmi'),
              icon: const Icon(Icons.monitor_weight_outlined),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const HomeBanner(),
            Expanded(
              child: GridView.builder(
                itemCount: appCategories.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: getCrossAxisCount(width),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  return CategoryTile(category: appCategories[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
