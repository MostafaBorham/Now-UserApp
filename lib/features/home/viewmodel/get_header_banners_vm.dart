import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/home/data/repo/header_banners_repo.dart';

/// Fetches the home header banners (`/api/v1/banners?type=header_main_page`).
///
/// Kept alive (the Home tab stays mounted) and kicked in the factory — unlike
/// the home feed it needs no `BuildContext`. The provider is only ever read by
/// `HomeTopBannerSectionView`, which mounts only when the feed carries a
/// `top_banner` section, so the request fires only when the section is enabled.
final getHeaderBannersProvider = StateNotifierProvider<GetHeaderBannersViewModel,
    AsyncValue<List<BannerModel>>>(
  (Ref ref) => GetHeaderBannersViewModel()..getHeaderBanners(),
);

class GetHeaderBannersViewModel
    extends StateNotifier<AsyncValue<List<BannerModel>>> {
  GetHeaderBannersViewModel() : super(const AsyncValue.loading());

  final HeaderBannersRepo _repo = HeaderBannersRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> getHeaderBanners() async {
    state = const AsyncValue.loading();

    final result = await _repo.getHeaderBanners();

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (List<BannerModel> banners) => AsyncValue.data(banners),
    );
  }
}
