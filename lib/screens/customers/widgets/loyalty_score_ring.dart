import 'package:flutter/material.dart';

class LoyaltyScoreRing extends StatelessWidget {
  final int score;

  const LoyaltyScoreRing({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (score >= 80) {
      color = Colors.amber;
    } else if (score >= 50) {
      color = Colors.blue;
    } else {
      color = Colors.grey;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            color: color,
            strokeWidth: 8,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$score', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const Text('Score', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}
