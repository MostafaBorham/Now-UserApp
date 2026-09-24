import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/support/data/models/complaint_request_model.dart';
import 'package:nowdelivery_user_app/features/support/data/models/complaint_response_model.dart';
import 'package:nowdelivery_user_app/features/support/presentation/widgets/file_complaint/complaint_photos_picker.dart';
import 'package:nowdelivery_user_app/features/support/viewmodel/submit_complaint_vm.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_description_field.dart';

class FileComplaintScreen extends ConsumerStatefulWidget {
  const FileComplaintScreen({super.key, required this.order});

  /// The order this complaint is about — its number becomes the ticket title.
  final OrderModel order;

  @override
  ConsumerState<FileComplaintScreen> createState() =>
      _FileComplaintScreenState();
}

class _FileComplaintScreenState extends ConsumerState<FileComplaintScreen> {
  final TextEditingController _descriptionController = TextEditingController();

  /// Drives the [AppWavedView] wave animation — the wave flattens while the
  /// content is scrolled away from the top and restores once it settles back.
  final ScrollController _scrollController = ScrollController();

  List<File> _images = const [];

  /// True while the photos are read and encoded, before the request starts.
  bool _isPreparing = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Surfaces a provider error as a snackbar, but on the *next* frame rather
  /// than inline in the `ref.listen` callback. The rating errors settle in the
  /// same state change that flips `isLoading` off — which tears down each
  /// card's loading animation and remounts its bar — so reading the theme
  /// (`context.colors`, an inherited-widget lookup) synchronously here would
  /// hit the mid-teardown tree and throw "deactivated widget's ancestor is
  /// unsafe", swallowing the snackbar. Deferring lets the tree settle first.
  void _showError(Object error) {
    if (!mounted) return;
    final String message = error.toString();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppToast.showError(context, message);
    });
  }

  /// Validates the form, then builds the request model (the order number,
  /// description + the picked photos mapped to base64 attachments — an empty
  /// list when none were picked) and hands it to the submit-complaint
  /// viewmodel. The success/error feedback is driven by the provider in
  /// [build].
  ///
  /// Reading and encoding the photos takes a moment before the request — and
  /// with it the provider's loading — starts, so [_isPreparing] holds the
  /// button meanwhile; each tap in that window used to file another ticket.
  Future<void> _onSubmit() async {
    if (_isPreparing) return;

    final String description = _descriptionController.text.trim();
    if (description.isEmpty) {
      AppToast.showError(context, LangKeys.complaintDescriptionRequiredKey.tr());
      return;
    }

    setState(() => _isPreparing = true);
    try {
      final ComplaintRequestModel complaint =
          await ComplaintRequestModel.fromComplaintInputs(
        orderNumber: widget.order.orderNumber,
        description: description,
        images: _images,
      );

      if (!mounted) return;

      ref
          .read(submitComplaintProvider.notifier)
          .submitComplaint(complaint: complaint);
    } finally {
      if (mounted) setState(() => _isPreparing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<ComplaintResponseModel?>>(
      submitComplaintProvider,
      (AsyncValue<ComplaintResponseModel?>? previous,
          AsyncValue<ComplaintResponseModel?> next) {
        next.whenOrNull(
          data: (ComplaintResponseModel? ticket) {
            if (ticket == null || !mounted) return;
            AppToast.showSuccess(
              context,
              LangKeys.complaintSubmittedSuccessfullyKey.tr(),
            );
            // Only leave the screen if it's still mounted and on the stack —
            // the user may have navigated away while the request was in flight.
            if (context.canPop()) context.pop();
          },
          error: (Object error, _) => _showError(error),
        );
      },
    );

    final bool isSubmitting =
        _isPreparing || ref.watch(submitComplaintProvider).isLoading;

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
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  // Owns the top spacing AppWavedView drops when a scroll
                  // controller is wired in, so it scrolls up with the content
                  // and flattens the wave.
                  padding: const EdgeInsets.only(top: 57),
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
                        // The backend's limit for a ticket's description.
                        maxLength: 10000,
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
        scrollController: _scrollController,
      ),
    );
  }
}
