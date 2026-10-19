import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_box_shadows.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/input_direction.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_context_menu.dart';

/// Bottom message composer: the attach button, a text field that grows up to
/// five lines, and the green send button, with the photos waiting to be sent
/// above them.
///
/// The send button is drawn straight from `send.svg` (which already includes
/// its own green circle), mirrored in right-to-left layouts.
class MessageInputBar extends StatelessWidget {
  const MessageInputBar({
    super.key,
    this.controller,
    this.onSend,
    this.onAttach,
    this.photos = const <String>[],
    this.onRemovePhoto,
  });

  final TextEditingController? controller;
  final VoidCallback? onSend;
  final VoidCallback? onAttach;

  /// Paths of the picked photos waiting to be sent.
  final List<String> photos;
  final ValueChanged<int>? onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: AppBorderRadius.brCircular6,
      borderSide: BorderSide(color: colors.neutral400),
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        boxShadow: AppBoxShadows.greyElevation2,
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              if (photos.isNotEmpty)
                _PendingPhotos(photos: photos, onRemove: onRemovePhoto),
              Row(
                spacing: 12,
                children: [
                  Semantics(
                    button: true,
                    label: LangKeys.attachPhotosKey.tr(),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onAttach,
                      // Taller hit area than the 24 px icon, same layout.
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Assets.media.images.svg.attach.svg(
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InputDirectionBuilder(
                      controller: controller,
                      builder: (context, typedDirection) => TextField(
                        contextMenuBuilder: appContextMenuBuilder,
                        controller: controller,
                        minLines: 1,
                        maxLines: 5,
                        maxLength: 4000,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.send,
                        textDirection: typedDirection,
                        onSubmitted: (_) => onSend?.call(),
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.tertiaryContainer,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          // 62 px for one line, as designed: Figma's 16 px
                          // padding sits around Cairo's 30 px line, the
                          // theme's line is 24.
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 19,
                          ),
                          border: border,
                          enabledBorder: border,
                          focusedBorder: border,
                          counterText: '',
                          hintText: LangKeys.supportMessageHintKey.tr(),
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: colors.neutral300,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Part of the field for tap-outside, so sending keeps the
                  // keyboard up for the next message.
                  TextFieldTapRegion(
                    child: GestureDetector(
                      onTap: onSend,
                      child: Assets.media.images.svg.send.svg(
                        width: 56,
                        height: 56,
                        matchTextDirection: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingPhotos extends StatelessWidget {
  const _PendingPhotos({required this.photos, required this.onRemove});

  final List<String> photos;
  final ValueChanged<int>? onRemove;

  static const double _size = 64;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return SizedBox(
      // Room for the remove badge that pokes out above each photo.
      height: _size + 6,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(top: 6),
        clipBehavior: Clip.none,
        itemCount: photos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) => SizedBox.square(
          dimension: _size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: AppBorderRadius.brCircular6,
                child: Image.file(
                  File(photos[index]),
                  width: _size,
                  height: _size,
                  cacheWidth: 192,
                  fit: BoxFit.cover,
                ),
              ),
              PositionedDirectional(
                top: -6,
                end: -6,
                child: GestureDetector(
                  onTap: onRemove == null ? null : () => onRemove!(index),
                  child: Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: colors.white,
                      size: 14,
                      semanticLabel: LangKeys.removePhotoKey.tr(),
                    ),
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
