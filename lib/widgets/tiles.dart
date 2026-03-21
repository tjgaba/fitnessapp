import 'package:flutter/material.dart';

class CategoryTile extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;

  const CategoryTile({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  bool isFavorite = false;

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleFavorite,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),

          // 🔥 Neon glow effect (dynamic)
          boxShadow: [
            BoxShadow(
              color: isFavorite
                  ? widget.color.withOpacity(0.8)
                  : widget.color.withOpacity(0.4),
              blurRadius: isFavorite ? 20 : 10,
              spreadRadius: isFavorite ? 3 : 1,
            ),
          ],

          border: Border.all(
            color: widget.color,
            width: isFavorite ? 2.5 : 1.5,
          ),
        ),

        child: Stack(
          children: [
            // ICON
            Positioned(
              top: 12,
              left: 12,
              child: Icon(widget.icon, color: widget.color, size: 26),
            ),

            // FAVORITE ICON
            Positioned(
              top: 12,
              right: 12,
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? widget.color : Colors.grey,
              ),
            ),

            // CENTER CONTENT
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Row: small accent icon + title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.icon, color: widget.color, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: widget.color.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isFavorite
                        ? "Added to favorites"
                        : "Start training",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}