import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';
import 'package:nowdelivery_user_app/features/home/data/repo/home_sections_repo.dart';







final getHomeSectionsProvider = StateNotifierProvider<GetHomeSectionsViewModel,
    AsyncValue<List<HomeSectionModel>>>(
  (Ref ref) => GetHomeSectionsViewModel(),
);

class GetHomeSectionsViewModel
    extends StateNotifier<AsyncValue<List<HomeSectionModel>>> {
  GetHomeSectionsViewModel() : super(const AsyncValue.loading());

  final HomeSectionsRepo _repo = HomeSectionsRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }




  Future<void> getHomeSections({
    required String platform,
    required String lang,
    double? lat,
    double? lng,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repo.getHomeSections(
      platform: platform,
      lang: lang,
      lat: lat,
      lng: lng,
    );

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (List<HomeSectionModel> sections) => AsyncValue.data(sections),
    );
  }
}
