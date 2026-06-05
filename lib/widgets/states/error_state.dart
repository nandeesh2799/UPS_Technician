import 'package:flutter/material.dart';
import '../error_boundary.dart';

class ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const ErrorState({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return CompactErrorWidget(
      message: error,
      onRetry: onRetry,
    );
  }
}
