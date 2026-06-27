import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/view/widgets/order/complaint_photos_picker.dart';
import 'package:nowdelivery_user_app/view/widgets/order/rating_card.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/text_fields/app_description_field.dart';

class FileComplaintScreen extends StatelessWidget {
  const FileComplaintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final LinearGradient screenGradient = LinearGradient(
      begin: AlignmentDirectional.centerStart,
      end: AlignmentDirectional.centerEnd,
      colors: [
        colors.onTertiaryFixedVariant,
        colors.onSurfaceVariant.withValues(alpha: 0.3),
      ],
    );
    final List<File> images = [];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AppWavedScaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            spacing: 10,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 15,
                    children: [
                      ComplaintPhotosPicker(
                        onChanged: (currentImages) {
                        },
                      ),
                      AppDescriptionField(hintTxt: LangKeys.tellUsMoreKey.tr()),
                      RatingCard(title: LangKeys.rateStoreQuestionKey.tr()),
                      RatingCard(title: LangKeys.rateDeliveryPersonQuestionKey.tr()),
                    ],
                  ),
                ),
              ),
              PrimaryAppButton(title: LangKeys.submitComplaintKey.tr()),
            ],
          ),
        ),
        appBarTitle: LangKeys.fileComplaintKey.tr(),
        canPop: Navigator.canPop(context),
      ),
    );
  }
}
