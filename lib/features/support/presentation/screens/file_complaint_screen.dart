import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/components/success_snackbar.dart';
import 'package:nowdelivery_user_app/features/support/data/models/complaint_request_model.dart';
import 'package:nowdelivery_user_app/features/support/data/models/complaint_response_model.dart';
import 'package:nowdelivery_user_app/features/support/presentation/widgets/file_complaint/complaint_photos_picker.dart';
import 'package:nowdelivery_user_app/features/support/viewmodel/submit_complaint_vm.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/rating_card.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_description_field.dart';

class FileComplaintScreen extends ConsumerStatefulWidget {
  const FileComplaintScreen({super.key});

  @override
  ConsumerState<FileComplaintScreen> createState() =>
      _FileComplaintScreenState();
}

class _FileComplaintScreenState extends ConsumerState<FileComplaintScreen> {
  static const int _initialRating = 4;

  final TextEditingController _descriptionController = TextEditingController();

  List<File> _images = const [];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  /// Validates the form, then builds the request model (description + the picked
  /// photos mapped to base64 attachments — an empty list when none were picked)
  /// and hands it to the submit-complaint viewmodel. The button's loading and
  /// the success/error feedback are driven by the provider in [build].
  Future<void> _onSubmit() async {
    final String description = _descriptionController.text.trim();
    if (description.isEmpty) {
      ErrorSnackBar.show(context, LangKeys.complaintDescriptionRequiredKey.tr());
      return;
    }

    final ComplaintRequestModel complaint =
        await ComplaintRequestModel.fromComplaintInputs(
      description: description,
      images: _images,
    );

    if (!mounted) return;

    ref
        .read(submitComplaintProvider.notifier)
        .submitComplaint(complaint: complaint);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<ComplaintResponseModel?>>(
      submitComplaintProvider,
      (AsyncValue<ComplaintResponseModel?>? previous,
          AsyncValue<ComplaintResponseModel?> next) {
        next.whenOrNull(
          data: (ComplaintResponseModel? ticket) {
            if (ticket == null) return;
            SuccessSnackBar.show(
              context,
              LangKeys.complaintSubmittedSuccessfullyKey.tr(),
            );
            // Only leave the screen if it's still mounted and on the stack —
            // the user may have navigated away while the request was in flight.
            if (mounted && context.canPop()) context.pop();
          },
          error: (Object error, _) =>
              ErrorSnackBar.show(context, error.toString()),
        );
      },
    );

    final bool isSubmitting = ref.watch(submitComplaintProvider).isLoading;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AppWavedView(
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
                        onChanged: (currentImages) => _images = currentImages,
                      ),
                      AppDescriptionField(
                        hintTxt: LangKeys.tellUsMoreKey.tr(),
                        controller: _descriptionController,
                      ),
                      // The rating cards are shown per the design, but ratings
                      // aren't part of the support-ticket request body, so their
                      // values are not collected for submission.
                      RatingCard(
                        title: LangKeys.rateStoreQuestionKey.tr(),
                        initialRating: _initialRating,
                        onRatingChanged: (_) {},
                      ),
                      RatingCard(
                        title: LangKeys.rateDeliveryPersonQuestionKey.tr(),
                        initialRating: _initialRating,
                        onRatingChanged: (_) {},
                      ),
                    ],
                  ),
                ),
              ),
              PrimaryAppButton(
                title: LangKeys.submitComplaintKey.tr(),
                isLoading: isSubmitting,
                onTap: _onSubmit,
              ),
            ],
          ),
        ),
        appBarTitle: LangKeys.fileComplaintKey.tr(),
        canPop: context.canPop(),
      ),
    );
  }
}
