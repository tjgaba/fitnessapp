import 'package:flutter/material.dart';
import '../data/category_data.dart';
import 'base_category_screen.dart';

class CardioScreen extends StatelessWidget {
  const CardioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final category = appCategories.firstWhere((c) => c.title == 'Cardio');
    return BaseCategoryScreen(category: category);
  }
}
