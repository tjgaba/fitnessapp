import 'package:flutter/material.dart';
import '../../data/category_data.dart';
import 'base_category_screen.dart';

class StrengthScreen extends StatelessWidget {
  const StrengthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final category = appCategories.firstWhere((c) => c.title == 'Strength');
    return BaseCategoryScreen(category: category);
  }
}


