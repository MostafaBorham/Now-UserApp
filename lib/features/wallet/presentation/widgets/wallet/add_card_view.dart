import 'package:auto_size_text/auto_size_text.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';

import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/add_card_form.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';

class AddCardView extends StatefulWidget {
  const AddCardView({super.key});

  @override
  State<AddCardView> createState() => _AddCardViewState();
}

class _AddCardViewState extends State<AddCardView> {
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    // Lift the whole sheet above the keyboard; the sheet grows by the keyboard
    // height (up to its max), then the middle area scrolls once capped.
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 10,
              children: [
                AutoSizeText(
                  LangKeys.addCardKey.tr(),
                  style: AppTextStyles.style18Medium.copyWith(
                    color: colors.black,
                  ),
                ),
                IconButton(padding: EdgeInsetsGeometry.zero,visualDensity: VisualDensity.compact, onPressed: () {
                  context.pop();
                }, icon: Icon(Icons.clear,size: 20,color: colors.black,))
              ],
            ),
            Flexible(child: AddCardForm()),
            2.hSpace,
            PrimaryAppButton(title: LangKeys.addNewCardKey.tr(),)
          ],
        ),
      ),
    );
  }
}