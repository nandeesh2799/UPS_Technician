import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PhotosGrid extends StatefulWidget {
  final List<String> photos;
  final Function(File)? onPhotoAdded;
  final Function(int)? onPhotoDeleted;
  final bool isEditable;

  const PhotosGrid({
    super.key, 
    required this.photos, 
    this.onPhotoAdded,
    this.onPhotoDeleted,
    this.isEditable = false,
  });

  @override
  State<PhotosGrid> createState() => _PhotosGridState();
}

class _PhotosGridState extends State<PhotosGrid> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    if (!widget.isEditable || widget.onPhotoAdded == null) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (image != null) {
      widget.onPhotoAdded!(File(image.path));
    }
  }

  void _viewPhoto(int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: widget.photos[index],
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            if (widget.isEditable && widget.onPhotoDeleted != null)
              Positioned(
                bottom: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 30),
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmDelete(index);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onPhotoDeleted?.call(index);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.photos.isEmpty && !widget.isEditable)
          const Text('No photos added.', style: TextStyle(color: Colors.grey))
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: widget.photos.length + (widget.isEditable ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == widget.photos.length) {
                return InkWell(
                  onTap: _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, color: Colors.grey.shade400, size: 24),
                        const SizedBox(height: 4),
                        const Text('Add', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              }

              return InkWell(
                onTap: () => _viewPhoto(index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: widget.photos[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey.shade200),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
