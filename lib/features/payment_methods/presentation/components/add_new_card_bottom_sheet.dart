import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_prefix_icon_button.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/add_card_form.dart';




class AddNewCardBottomSheet extends StatelessWidget {
  const AddNewCardBottomSheet({super.key});



  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const AddNewCardBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 12,
        left: 16,
        right: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _DragHandle(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  LangKeys.addNewPaymentCardKey.tr(),
                  style: AppTextStyles.style18SemiBold.copyWith(
                    color: context.colors.tertiaryContainer,
                  ),
                ),
              ),
              InkWell(
                onTap: () => context.pop(),
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 24,
                    color: context.colors.tertiaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Flexible(
            child: AddCardForm(
              fieldColor: context.colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 20),
          PrimaryAppPrefixIconButton(
            title: LangKeys.addKey.tr(),
            prefixIcon: Assets.media.images.svg.addCircle.svg(),
            onTap: () => context.pop(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}


class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: context.colors.neutral300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
