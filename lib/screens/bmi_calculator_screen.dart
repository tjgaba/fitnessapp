import 'package:flutter/material.dart';

import '../app_router.dart';
import '../utils/bmi_calculator.dart';
import '../widgets/app_drawer.dart';
import '../widgets/bmi_calculate_button.dart';
import '../widgets/bmi_input_card.dart';
import '../widgets/bmi_result_card.dart';

class BmiCalculatorScreen extends StatefulWidget {
  const BmiCalculatorScreen({super.key});

  @override
  State<BmiCalculatorScreen> createState() => _BmiCalculatorScreenState();
}

class _BmiCalculatorScreenState extends State<BmiCalculatorScreen> {
  double _heightCm = 175;
  double _weightKg = 76;
  double? _bmi;
  String? _category;

  Color get _resultColor {
    if (_bmi == null) return Colors.blueAccent;
    if (_bmi! < 18.5) return Colors.blueAccent;
    if (_bmi! < 25.0) return Colors.green;
    if (_bmi! < 30.0) return Colors.orange;
    return Colors.redAccent;
  }

  void _calculate() {
    final bmi = calculateBmi(_weightKg, _heightCm);
    setState(() {
      _bmi = bmi;
      _category = bmiCategory(bmi);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      drawer: AppDrawer(
        currentRouteName: AppRoute.bmi.name,
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          'BMI Calculator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [DrawerBackAction()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFECFEFF), Color(0xFFEFF6FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.blueAccent.withValues(alpha: 0.18),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check your body mass index',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Adjust your height and weight, then calculate your BMI with a custom interactive control.',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              BmiInputCard(
                title: 'Height',
                value: _heightCm,
                unit: 'cm',
                icon: Icons.height,
                color: Colors.blueAccent,
                min: 120,
                max: 220,
                divisions: 100,
                onChanged: (value) => setState(() => _heightCm = value),
              ),
              const SizedBox(height: 14),
              BmiInputCard(
                title: 'Weight',
                value: _weightKg,
                unit: 'kg',
                icon: Icons.monitor_weight_outlined,
                color: Colors.orange,
                min: 30,
                max: 200,
                divisions: 170,
                onChanged: (value) => setState(() => _weightKg = value),
              ),
              const SizedBox(height: 18),
              BmiCalculateButton(onTap: _calculate),
              const SizedBox(height: 18),
              BmiResultCard(
                bmi: _bmi,
                category: _category,
                color: _resultColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
