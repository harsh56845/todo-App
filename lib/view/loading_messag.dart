import 'package:flutter/material.dart';

class LoadingMessage extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;

  const LoadingMessage({
    super.key,
    this.message = "Loading, please wait...\nHave a great day! ☀️",
    this.icon = Icons.sentiment_satisfied_alt,
    this.color = Colors.deepPurple,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 12,
        shadowColor: color.withAlpha(100), // approx 0.4 opacity
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: const Color.fromARGB(230, 255, 255, 255), // 90% white
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: color, strokeWidth: 5),
              const SizedBox(height: 20),
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
