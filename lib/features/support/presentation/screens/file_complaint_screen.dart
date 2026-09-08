import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/components/success_snackbar.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/support/data/models/complaint_request_model.dart';
import 'package:nowdelivery_user_app/features/support/data/models/complaint_response_model.dart';
import 'package:nowdelivery_user_app/features/support/data/models/rate_request_model.dart';
import 'package:nowdelivery_user_app/features/support/data/models/rate_response_model.dart';
import 'package:nowdelivery_user_app/features/support/presentation/widgets/file_complaint/complaint_photos_picker.dart';
import 'package:nowdelivery_user_app/features/support/viewmodel/rate_delivery_man_vm.dart';
import 'package:nowdelivery_user_app/features/support/viewmodel/rate_store_vm.dart';
import 'package:nowdelivery_user_app/features/support/viewmodel/submit_complaint_vm.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/rating_card.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_description_field.dart';

class FileComplaintScreen extends ConsumerStatefulWidget {
  const FileComplaintScreen({super.key, required this.order});

  /// The order this complaint / rating is about — supplies the ids sent to the
  /// rating endpoints (order id as the source, store/driver id as the rateable).
  final OrderModel order;

  @override
  ConsumerState<FileComplaintScreen> createState() =>
      _FileComplaintScreenState();
}

class _FileComplaintScreenState extends ConsumerState<FileComplaintScreen> {
  static const int _initialRating = 4;

  final TextEditingController _descriptionController = TextEditingController();

  /// Drives the [AppWavedView] wave animation — the wave flattens while the
  /// content is scrolled away from the top and restores once it settles back.
  final ScrollController _scrollController = ScrollController();

  List<File> _images = const [];

  /// The committed star values shown by the two cards. They only advance once
  /// the matching rating request succeeds (driven by the response's `score`);
  /// on error they stay put and the card reverts its bar.
  int _storeRating = _initialRating;
  int _deliveryRating = _initialRating;

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
      if (mounted) ErrorSnackBar.show(context, message);
    });
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

  /// Rates the store: order id as the source, the order's vendor id as the
  /// rateable, the tapped stars as the score and the emotion text as comment.
  void _onStoreRatingChanged(int rating, String comment) {
    ref.read(rateStoreProvider.notifier).rateStore(
          rate: RateRequestModel.store(
            orderId: widget.order.id ?? 0,
            storeId: widget.order.vendor.id ?? 0,
            score: rating,
            comment: comment,
          ),
        );
  }

  /// Rates the delivery man: order id as the source, the order's driver id as
  /// the rateable, the tapped stars as the score and the emotion text as comment.
  void _onDeliveryRatingChanged(int rating, String comment) {
    ref.read(rateDeliveryManProvider.notifier).rateDeliveryMan(
          rate: RateRequestModel.deliveryMan(
            orderId: widget.order.id ?? 0,
            deliveryManId: widget.order.driver?.id ?? 0,
            score: rating,
            comment: comment,
          ),
        );
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
            SuccessSnackBar.show(
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

    // Store rating: commit the returned score on success, show an error
    // snackbar on failure — both only while the screen is still mounted.
    ref.listen<AsyncValue<RateResponseModel?>>(
      rateStoreProvider,
      (AsyncValue<RateResponseModel?>? previous,
          AsyncValue<RateResponseModel?> next) {
        next.whenOrNull(
          data: (RateResponseModel? rating) {
            if (rating == null || !mounted) return;
            setState(() => _storeRating = rating.score ?? _storeRating);
          },
          error: (Object error, _) => _showError(error),
        );
      },
    );

    // Delivery-man rating: same success/error handling as the store card.
    ref.listen<AsyncValue<RateResponseModel?>>(
      rateDeliveryManProvider,
      (AsyncValue<RateResponseModel?>? previous,
          AsyncValue<RateResponseModel?> next) {
        next.whenOrNull(
          data: (RateResponseModel? rating) {
            if (rating == null || !mounted) return;
            setState(() => _deliveryRating = rating.score ?? _deliveryRating);
          },
          error: (Object error, _) => _showError(error),
        );
      },
    );

    final bool isSubmitting = ref.watch(submitComplaintProvider).isLoading;
    final bool isRatingStore = ref.watch(rateStoreProvider).isLoading;
    final bool isRatingDelivery = ref.watch(rateDeliveryManProvider).isLoading;

    // Each rating card is only offered when the order actually carries the
    // party it rates: the store slice is always present as an object but empty
    // (null id) when there's no vendor, and the courier is null until one is
    // assigned — so gate on real data, not mere non-null.
    final bool hasStore = widget.order.vendor.id != null;
    final bool hasDeliveryMan = widget.order.driver != null;

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
                      ),
                      if (hasStore)
                        RatingCard(
                          title: LangKeys.rateStoreQuestionKey.tr(),
                          rating: _storeRating,
                          isLoading: isRatingStore,
                          onRatingChanged: _onStoreRatingChanged,
                        ),
                      if (hasDeliveryMan)
                        RatingCard(
                          title: LangKeys.rateDeliveryPersonQuestionKey.tr(),
                          rating: _deliveryRating,
                          isLoading: isRatingDelivery,
                          onRatingChanged: _onDeliveryRatingChanged,
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
