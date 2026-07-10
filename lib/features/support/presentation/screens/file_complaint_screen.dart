
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/support/presentation/widgets/file_complaint/complaint_photos_picker.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/rating_card.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_description_field.dart';

class FileComplaintScreen extends StatelessWidget {
  const FileComplaintScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              PrimaryAppButton(title: LangKeys.submitComplaintKey.tr(),onTap: () => context.pop(),),
            ],
          ),
        ),
        appBarTitle: LangKeys.fileComplaintKey.tr(),
        canPop: context.canPop(),
      ),
    );
  }
}
