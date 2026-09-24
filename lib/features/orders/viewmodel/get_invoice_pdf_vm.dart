import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/orders/data/repo/orders_repo.dart';

/// Single task: download an order's invoice PDF to a local file for the
/// in-app viewer, keyed by its `invoice_pdf_url`.
///
/// The download starts on first watch (`..load()` in the provider factory);
/// `load()` is also the retry. The state holds the file's path.
final getInvoicePdfProvider = StateNotifierProvider.autoDispose
    .family<GetInvoicePdfViewModel, AsyncValue<String>, String>(
      (Ref ref, String url) => GetInvoicePdfViewModel(url: url)..load(),
    );

class GetInvoicePdfViewModel extends StateNotifier<AsyncValue<String>> {
  GetInvoicePdfViewModel({required this.url})
    : super(const AsyncValue<String>.loading());

  final OrdersRepo _repo = OrdersRepo();

  /// The invoice's authenticated URL, kept so a retry asks for the same file.
  final String url;

  Future<void> load() async {
    state = const AsyncValue<String>.loading();

    final Either<Failure, String> result = await _repo.downloadInvoice(
      url: url,
    );

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue<String>.error(failure.message, StackTrace.current),
      AsyncValue<String>.data,
    );
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
