import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/settings/data/models/app_info_model.dart';
import 'package:nowdelivery_user_app/features/settings/data/repo/app_info_repo.dart';

/// Single task: fetch the application information (FAQs + terms/privacy/about)
/// for the settings, FAQ and privacy screens.
///
/// Kept alive (not `autoDispose`) so the fetched data is preloaded once on the
/// splash screen and reused across the settings/FAQ/privacy screens. The fetch
/// fires as soon as the view model is constructed — the first time the provider
/// is read/watched — so screens only need to `ref.watch(getAppInfoProvider)`
/// and render the [AsyncValue]. Retry with
/// `ref.read(getAppInfoProvider.notifier).getAppInfo()`.
final getAppInfoProvider =
    StateNotifierProvider<GetAppInfoViewModel, AsyncValue<AppInfoModel>>(
  (Ref ref) => GetAppInfoViewModel()..getAppInfo(),
);

class GetAppInfoViewModel extends StateNotifier<AsyncValue<AppInfoModel>> {
  GetAppInfoViewModel() : super(const AsyncValue.loading());

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
