import 'package:flutter/material.dart';
import '../data/category_data.dart';
import 'base_category_screen.dart';

class FlexibilityScreen extends StatelessWidget {
  const FlexibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final category =
        appCategories.firstWhere((c) => c.title == 'Flexibility');
    return BaseCategoryScreen(category: category);
  }
}
