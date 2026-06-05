import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../utils/validators.dart';
import '../widgets/photos_grid.dart';

class Step3Diagnostics extends StatelessWidget {
  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController problemController;
  final TextEditingController remarksController;
  final List<String> photos;
  final Function(File) onPhotoAdded;

  const Step3Diagnostics({
    super.key,
    required this.brandController,
    required this.modelController,
    required this.problemController,
    required this.remarksController,
    required this.photos,
    required this.onPhotoAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Technical Diagnostics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Provide device specifics and the reported issue.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        TextFormField(
          controller: brandController,
          decoration: const InputDecoration(labelText: 'UPS Brand (e.g. APC, Microtek)', prefixIcon: Icon(Icons.branding_watermark)),
          validator: Validators.required,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: modelController,
          decoration: const InputDecoration(labelText: 'UPS Model', prefixIcon: Icon(Icons.model_training)),
          validator: Validators.required,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: problemController,
          decoration: const InputDecoration(labelText: 'Problem Description', prefixIcon: Icon(Icons.report_problem)),
          maxLines: 3,
          validator: Validators.required,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: remarksController,
          decoration: const InputDecoration(labelText: 'Technician Remarks (Optional)', prefixIcon: Icon(Icons.engineering)),
          maxLines: 2,
        ),
        const SizedBox(height: 24),
        const Text('Device Photos', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        PhotosGrid(
          photos: photos,
          isEditable: true,
          onPhotoAdded: onPhotoAdded,
        ),
      ],
    );
  }
}
