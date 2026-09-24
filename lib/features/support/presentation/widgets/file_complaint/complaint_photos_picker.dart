import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class ComplaintPhotosPicker extends StatefulWidget {
  const ComplaintPhotosPicker({
    super.key,
    required this.onChanged,
  });


  final ValueChanged<List<File>> onChanged;

  @override
  State<ComplaintPhotosPicker> createState() => _ComplaintPhotosPickerState();
}

class _ComplaintPhotosPickerState extends State<ComplaintPhotosPicker> {
  final ImagePicker _picker = ImagePicker();

  final List<File> _images = [];
  bool _isPicking = false;

  static const int _maxImages = 5;
  static const double _spacing = 8;
  static const double _runSpacing = 8;

  Future<void> _pickImage() async {
    if (_isPicking) return;
    if (_images.length >= _maxImages) return;

    setState(() {
      _isPicking = true;
    });

    try {
      // Resized on the device: the photos travel base64-encoded (+33 %) in one
      // JSON body, and the API's proxy takes 8 MB — two full-size camera
      // photos already exceed it.
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (picked != null) {
        final file = File(picked.path);

        final alreadyExists = _images.any((e) => e.path == file.path);
        if (!alreadyExists) {
          setState(() {
            _images.add(file);
          });

          widget.onChanged(List<File>.unmodifiable(_images));
        }
      }
    } catch (_) {
      // E.g. photo access denied — say so rather than doing nothing.
      if (mounted) AppToast.showError(context, LangKeys.imagePickingErrorKey);
    } finally {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
      }
    }
  }

  void _removeImageAt(int index) {
    if (index < 0 || index >= _images.length) return;

    setState(() {
      _images.removeAt(index);
    });

    widget.onChanged(List<File>.unmodifiable(_images));
  }

  @override
  Widget build(BuildContext context) {
    final canAddMore = _images.length < _maxImages;
    final AppColorScheme colors = context.colors;




    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Text(LangKeys.complaintPhotosKey.tr(),overflow: TextOverflow.visible,style: AppTextStyles.style16Medium.copyWith(
            color: colors.black
          ),),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.start,
            spacing: _spacing,
            runSpacing: _runSpacing,
            children: [
              for (int i = 0; i < _images.length; i++)
                _PickedImageTile(
                  imageFile: _images[i],
                  onRemove: () => _removeImageAt(i),
                ),

              if (canAddMore)
                _AddImageTile(
                  isLoading: _isPicking,
                  onTap: _pickImage,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddImageTile extends StatelessWidget {
  const _AddImageTile({
    required this.isLoading,
    required this.onTap,
  });

  final bool isLoading;
  final VoidCallback onTap;

  static const double _size = 72;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return SizedBox(
      width: _size,
      height: _size,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: colors.neutral400.withValues(alpha: 0.2),
              borderRadius: AppBorderRadius.brCircular6,
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  :  Icon(
                Icons.add,
                size: 24,
                color: colors.tertiaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickedImageTile extends StatelessWidget {
  const _PickedImageTile({
    required this.imageFile,
    required this.onRemove,
  });

  final File imageFile;
  final VoidCallback onRemove;

  static const double _size = 72;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: AppBorderRadius.brCircular6,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  imageFile,
                  width: _size,
                  height: _size,
                  fit: BoxFit.cover,
                ),




                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.6, 1],
                      colors: [colors.white.withValues(alpha: 0), colors.white],
                    ),
                  ),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            top: -6,
            end: -6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.close,
                  color: colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
