import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/home/data/repo/header_banners_repo.dart';







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
