import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

/// Circular avatar with a camera badge. Tapping it opens the gallery to pick a
/// profile photo; the placeholder image is shown until one is chosen.
class ProfileAvatarPicker extends StatefulWidget {
  const ProfileAvatarPicker({super.key, this.onChanged, this.radius = 56});

  final ValueChanged<File>? onChanged;
  final double radius;

  @override
  State<ProfileAvatarPicker> createState() => _ProfileAvatarPickerState();
}

class _ProfileAvatarPickerState extends State<ProfileAvatarPicker> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isPicking = false;

  Future<void> _pick() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) {
        final File file = File(picked.path);
        setState(() => _image = file);
        widget.onChanged?.call(file);
      }
    } catch (e) {
      debugPrint('${LangKeys.imagePickingErrorKey.tr()}: $e');
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.radius * 2;
    return GestureDetector(
      onTap: _pick,
      child: SizedBox(
        width: size,
        height: size,
        child: ClipOval(
          child: Stack(
            children: [
              Positioned.fill(
                child: _image != null
                    ? Image.file(_image!, fit: BoxFit.cover)
                    : Assets.media.images.png.profileImgPlacholder.image(
                        fit: BoxFit.cover,
                      ),
              ),
              PositionedDirectional(
                start: 0,
                end: 0,
                bottom: 0,
                child: Container(
                  height: widget.radius * 0.6,
                  color: Colors.black.withValues(alpha: 0.45),
                  alignment: Alignment.center,
                  child: _isPicking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.photo_camera,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
