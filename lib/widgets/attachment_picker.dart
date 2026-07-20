import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';

/// Lets the user attach a single photo, picked from the camera or gallery.
///
/// Shows a picker button when empty and a thumbnail with a remove action
/// once a photo is selected. Reports the picked image bytes (or `null` on
/// removal) via [onChanged]; the caller owns the actual value.
class AttachmentPicker extends StatefulWidget {
  const AttachmentPicker({super.key, required this.onChanged});

  final ValueChanged<Uint8List?> onChanged;

  @override
  State<AttachmentPicker> createState() => _AttachmentPickerState();
}

class _AttachmentPickerState extends State<AttachmentPicker> {
  Uint8List? _bytes;
  bool _isPicking = false;

  Future<void> _pick() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Câmera'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeria'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    setState(() => _isPicking = true);
    final file = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1600,
    );
    final bytes = await file?.readAsBytes();
    if (!mounted) return;
    setState(() {
      _isPicking = false;
      _bytes = bytes ?? _bytes;
    });
    if (bytes != null) widget.onChanged(bytes);
  }

  void _remove() {
    setState(() => _bytes = null);
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Foto (opcional)', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        _bytes == null ? _buildPickButton() : _buildPreview(),
      ],
    );
  }

  Widget _buildPickButton() {
    return OutlinedButton.icon(
      onPressed: _isPicking ? null : _pick,
      icon: _isPicking
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.add_a_photo_outlined),
      label: Text(_isPicking ? 'Abrindo...' : 'Anexar foto'),
    );
  }

  Widget _buildPreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.memory(
            _bytes!,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: InkWell(
            onTap: _remove,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.textOnPrimary,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
