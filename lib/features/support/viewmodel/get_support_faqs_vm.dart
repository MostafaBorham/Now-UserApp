import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/settings/data/models/faq_model.dart';
import 'package:nowdelivery_user_app/features/support/data/repo/support_repo.dart';

/// Single task: fetch the support FAQs (the `data.faqs` list of the
/// about-section application information).
///
/// The fetch fires as soon as the view model is constructed — the first time
/// the provider is read/watched — so screens only need to
/// `ref.watch(getSupportFaqsProvider)` and render the [AsyncValue]. Retry with
/// `ref.read(getSupportFaqsProvider.notifier).getSupportFaqs()`.
final getSupportFaqsProvider =
    StateNotifierProvider.autoDispose<GetSupportFaqsViewModel,
        AsyncValue<List<FaqModel>>>(
      (Ref ref) => GetSupportFaqsViewModel()..getSupportFaqs(),
    );

class GetSupportFaqsViewModel
    extends StateNotifier<AsyncValue<List<FaqModel>>> {
  GetSupportFaqsViewModel() : super(const AsyncValue.loading());

  final SupportRepo _repo = SupportRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> getSupportFaqs() async {
    state = const AsyncValue.loading();

    final result = await _repo.getSupportFaqs();

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (List<FaqModel> faqs) => AsyncValue.data(faqs),
    );
  }
}
