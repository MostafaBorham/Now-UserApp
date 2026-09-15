import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';









class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.title,
    required this.address,
    this.isDefault = false,
    this.onSelect,
    this.onEdit,
  });


  final String title;


  final String address;


  final bool isDefault;


  final VoidCallback? onSelect;


  final VoidCallback? onEdit;

  static const double _radius = 20;



  static const double _leadingSlot = 20;
  static const double _leadingGap = 12;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(_radius),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          color: isDefault ? null : context.colors.onTertiaryContainer,
          gradient: isDefault
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.colors.scrim,
                    context.colors.primary100,
                  ],
                )
              : null,
          border: isDefault
              ? Border.all(color: context.colors.primary100)
              : null,
        ),
        child: InkWell(
          onTap: onSelect,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    _Radio(selected: isDefault),
                    const SizedBox(width: _leadingGap),
                    Expanded(
                      child: Text(
                        isDefault
                            ? '$title ${LangKeys.defaultAddress.tr()}'
                            : title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.colors.tertiaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _EditButton(onTap: onEdit),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Assets.media.images.svg.pin.svg(
                        width: _leadingSlot,
                        height: _leadingSlot,
                      ),
                    ),
                    const SizedBox(width: _leadingGap),
                    Expanded(
                      child: Text(
                        address,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.3,
                          fontWeight: FontWeight.w400,
                          color: context.colors.onPrimaryFixed,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AddressCard._leadingSlot,
      height: AddressCard._leadingSlot,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? context.colors.primary500Main
              : context.colors.neutral300,
          width: selected ? 2 : 1.5,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.primary500Main,
                ),
              ),
            )
          : null,
    );
  }
}


class _EditButton extends StatelessWidget {
  const _EditButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Assets.media.images.svg.edit.svg(width: 22, height: 22),
        ),
      ),
    );
  }
}
