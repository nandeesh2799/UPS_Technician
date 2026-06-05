import 'package:flutter/material.dart';

class NotesThread extends StatelessWidget {
  final String notes;

  const NotesThread({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const Text('No internal notes recorded.', style: TextStyle(color: Colors.grey));

    // Simulate chat thread from a single string for now
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Text(notes),
    );
  }
}
