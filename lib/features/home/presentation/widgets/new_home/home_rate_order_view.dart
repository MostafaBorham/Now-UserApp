import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/animated_success_badge.dart';

/// Opens the "rate your order" prompt: a delivered order asking the shopper to
/// rate the store it came from. [onRate] runs once the sheet is dismissed.
Future<void> showRateOrderSheet(
  BuildContext context, {
  required String storeName,
  required String storeLogoUrl,
  VoidCallback? onRate,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: context.colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext sheetContext) => HomeRateOrderView(
      storeName: storeName,
      storeLogoUrl: storeLogoUrl,
      onRate: () {
        sheetContext.pop();
        onRate?.call();
      },
    ),
  );
}

/// Bottom sheet prompting the shopper to rate a store their order arrived from.
class HomeRateOrderView extends StatelessWidget {
  const HomeRateOrderView({
    super.key,
    required this.storeName,
    required this.storeLogoUrl,
    this.onRate,
  });

  final String storeName;
  final String storeLogoUrl;
  final GestureTapCallback? onRate;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    LangKeys.orderReadyToRateKey.tr(),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    style: AppTextStyles.style20SemiBold.copyWith(
                      color: colors.black,
                    ),
                  ),
                ),
                8.wSpace,
                GestureDetector(
                  onTap: context.pop,
                  child: Icon(Icons.close, size: 20, color: colors.black),
                ),
              ],
            ),
            20.hSpace,
            AnimatedSuccessBadge(imageUrl: storeLogoUrl, label: storeName),
            20.hSpace,
            Text(
              LangKeys.orderArrivedRatePromptKey.tr(
                namedArgs: <String, String>{'store': storeName},
              ),
              textAlign: TextAlign.center,
              softWrap: true,
              overflow: TextOverflow.visible,
              style: AppTextStyles.style18SemiBold.copyWith(
                color: colors.black,
              ),
            ),
            20.hSpace,
            PrimaryAppButton(
              title: LangKeys.rateOrderKey.tr(),
              titleStyle: AppTextStyles.style16Medium,
              onTap: onRate,
            ),
          ],
        ),
      ),
    );
  }
}
