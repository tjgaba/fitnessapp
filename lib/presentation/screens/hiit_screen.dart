import 'package:flutter/material.dart';
import '../../data/category_data.dart';
import 'base_category_screen.dart';

class HiitScreen extends StatelessWidget {
  const HiitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final category = appCategories.firstWhere((c) => c.title == 'HIIT');
    return BaseCategoryScreen(category: category);
  }
}


