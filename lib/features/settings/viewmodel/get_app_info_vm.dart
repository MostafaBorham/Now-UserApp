import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/settings/data/models/app_info_model.dart';
import 'package:nowdelivery_user_app/features/settings/data/repo/app_info_repo.dart';

/// Single task: fetch the application information (FAQs + terms/privacy/about)
/// for the settings, FAQ and privacy screens.
///
/// The fetch starts as soon as the provider is first watched, so screens only
/// need to `ref.watch(getAppInfoProvider)` and render the [AsyncValue].
/// Retry with `ref.read(getAppInfoProvider.notifier).getAppInfo()`.
final getAppInfoProvider =
    StateNotifierProvider.autoDispose<GetAppInfoViewModel,
        AsyncValue<AppInfoModel>>(
  (Ref ref) =>
      GetAppInfoViewModel(const AsyncValue.loading())..getAppInfo(),
);

class GetAppInfoViewModel extends StateNotifier<AsyncValue<AppInfoModel>> {
  GetAppInfoViewModel(super.initialState);

  final AppInfoRepo _repo = AppInfoRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> getAppInfo() async {
    state = const AsyncValue.loading();

    final result = await _repo.getAppInfo();

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (AppInfoModel appInfo) => AsyncValue.data(appInfo),
    );
  }
}
