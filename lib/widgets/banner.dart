import 'package:flutter/material.dart';

class FeaturedBanner extends StatefulWidget {
  const FeaturedBanner({super.key});

  @override
  State<FeaturedBanner> createState() => _FeaturedBannerState();
}

class _FeaturedBannerState extends State<FeaturedBanner> {
  bool isPressed = false;

  void handlePress() {
    setState(() => isPressed = true);

    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() => isPressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),

      height: 170,
      margin: const EdgeInsets.only(bottom: 20),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,

        // 🔥 Glow effect
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(isPressed ? 0.5 : 0.25),
            blurRadius: isPressed ? 25 : 15,
            spreadRadius: isPressed ? 4 : 2,
          ),
        ],
      ),

      child: Stack(
        children: [
          // 🔥 BACKGROUND ACCENT
          Positioned(
            bottom: -30,
            right: -30,
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // 🔹 TEXT CONTENT
          const Positioned(
            top: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Workout of the Day",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Full Body Burn 🔥",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          // ✅ FIXED BUTTON (VISIBLE + INTERACTIVE)
          Positioned(
            bottom: 15,
            right: 15,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: handlePress,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(14),

                    // 🔥 glow + visibility boost
                    border: Border.all(
                      color: Colors.blueAccent,
                      width: 1.5,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(
                          isPressed ? 0.8 : 0.4,
                        ),
                        blurRadius: isPressed ? 15 : 8,
                      ),
                    ],
                  ),
                  child: const Text(
                    "START",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}