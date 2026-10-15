import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';

/// The sheet every photo picker opens: take a photo or choose one from the
/// gallery, plus "Remove photo" when [onRemove] is given (it runs as the sheet
/// closes). Resolves to the source to pick from, or null when the sheet was
/// dismissed or the photo removed.
Future<ImageSource?> showImageSourceSheet(
  BuildContext context, {
  VoidCallback? onRemove,
}) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    builder: (BuildContext sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(
              Icons.photo_camera_outlined,
              color: Colors.black,
            ),
            title: Text(
              LangKeys.takePhotoKey.tr(),
              style: TextStyle(color: Colors.black),
            ),
            onTap: () => sheetContext.pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(
              Icons.photo_library_outlined,
              color: Colors.black,
            ),
            title: Text(
              LangKeys.chooseFromGalleryKey.tr(),
              style: TextStyle(color: Colors.black),
            ),
            onTap: () => sheetContext.pop(ImageSource.gallery),
          ),
          if (onRemove != null)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.black),
              title: Text(
                LangKeys.removePhotoKey.tr(),
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                sheetContext.pop();
                onRemove();
              },
            ),
        ],
      ),
    ),
  );
}
