import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/repo/pdf_file_repo.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';

/// Single task: download the PDF at a URL to a local file for the in-app
/// viewer, keyed by that URL.
///
/// The download starts on first watch (`..load()` in the provider factory);
/// `load()` is also the retry. The state holds the file's path.
final getPdfFileProvider = StateNotifierProvider.autoDispose
    .family<GetPdfFileViewModel, AsyncValue<String>, String>(
      (Ref ref, String url) => GetPdfFileViewModel(url: url)..load(),
    );

class GetPdfFileViewModel extends StateNotifier<AsyncValue<String>> {
  GetPdfFileViewModel({required this.url})
    : super(const AsyncValue<String>.loading());

  final PdfFileRepo _repo = PdfFileRepo();

  /// The file's authenticated URL, kept so a retry asks for the same file.
  final String url;

  Future<void> load() async {
    state = const AsyncValue<String>.loading();

    final Either<Failure, String> result = await _repo.download(url: url);

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
