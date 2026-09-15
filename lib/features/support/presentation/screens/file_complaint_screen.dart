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



  final OrderModel order;

  @override
  ConsumerState<FileComplaintScreen> createState() =>
      _FileComplaintScreenState();
}

class _FileComplaintScreenState extends ConsumerState<FileComplaintScreen> {
  static const int _initialRating = 1;

  final TextEditingController _descriptionController = TextEditingController();



  final ScrollController _scrollController = ScrollController();

  List<File> _images = const [];




  int _storeRating = _initialRating;
  int _deliveryRating = _initialRating;

  @override
  void dispose() {
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }








  void _showError(Object error) {
    if (!mounted) return;
    final String message = error.toString();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppToast.showError(context, message);
    });
  }





  Future<void> _onSubmit() async {
    final String description = _descriptionController.text.trim();
    if (description.isEmpty) {
      AppToast.showError(context, LangKeys.complaintDescriptionRequiredKey.tr());
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
            AppToast.showSuccess(
              context,
              LangKeys.complaintSubmittedSuccessfullyKey.tr(),
            );


            if (context.canPop()) context.pop();
          },
          error: (Object error, _) => _showError(error),
        );
      },
    );



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
