import 'package:flutter/material.dart';

class BmiCalculateButton extends StatefulWidget {
  final VoidCallback onTap;

  const BmiCalculateButton({
    super.key,
    required this.onTap,
  });

  @override
  State<BmiCalculateButton> createState() => _BmiCalculateButtonState();
}

class _BmiCalculateButtonState extends State<BmiCalculateButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          setState(() => _pressed = true);
          Future.delayed(const Duration(milliseconds: 140), () {
            if (mounted) {
              setState(() => _pressed = false);
            }
          });
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 
                  _pressed ? 0.42 : 0.24,
                ),
                blurRadius: _pressed ? 24 : 14,
                spreadRadius: _pressed ? 3 : 1,
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.monitor_weight_outlined,
                  color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text(
                'Calculate BMI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


