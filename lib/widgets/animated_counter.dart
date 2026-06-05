import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class AnimatedCounter extends StatelessWidget {
  final num count;
  final bool isCurrency;
  final TextStyle? style;

  const AnimatedCounter({
    super.key,
    required this.count,
    this.isCurrency = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: count.toDouble()),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        String displayValue;
        if (isCurrency) {
          displayValue = Formatters.currency(value);
        } else if (count is int) {
          displayValue = value.toInt().toString();
        } else {
          displayValue = value.toStringAsFixed(1);
        }
        return Text(displayValue, style: style);
      },
    );
  }
}
