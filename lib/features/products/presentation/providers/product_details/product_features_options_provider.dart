import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/scroll_spy/sections_scroll_spy.dart';

class ProductFeaturesOptionsState {
  const ProductFeaturesOptionsState({
    this.selectedSectionIndex = 0,
    this.selectedOptionIndexes = const {},
    this.collapsedSectionIndexes = const {},
  });

  final int selectedSectionIndex;
  final Map<int, int> selectedOptionIndexes;
  final Set<int> collapsedSectionIndexes;

  ProductFeaturesOptionsState copyWith({
    int? selectedSectionIndex,
    Map<int, int>? selectedOptionIndexes,
    Set<int>? collapsedSectionIndexes,
  }) {
    return ProductFeaturesOptionsState(
      selectedSectionIndex: selectedSectionIndex ?? this.selectedSectionIndex,
      selectedOptionIndexes:
          selectedOptionIndexes ?? this.selectedOptionIndexes,
      collapsedSectionIndexes:
          collapsedSectionIndexes ?? this.collapsedSectionIndexes,
    );
  }
}

final productFeaturesOptionsProvider =
    StateNotifierProvider.autoDispose<
      ProductFeaturesOptionsNotifier,
      ProductFeaturesOptionsState
    >((Ref ref) => ProductFeaturesOptionsNotifier());

class ProductFeaturesOptionsNotifier
    extends StateNotifier<ProductFeaturesOptionsState> {
  ProductFeaturesOptionsNotifier() : super(const ProductFeaturesOptionsState());

  late final SectionsScrollSpy sectionsScrollSpy = SectionsScrollSpy(
    onSectionAtTop: _selectSectionAtTop,
  );

  Future<void> selectSection(int sectionIndex) {
    _selectAndExpandSection(sectionIndex);
    return sectionsScrollSpy.scrollToSection(sectionIndex);
  }

  void toggleSection(int sectionIndex) {
    final Set<int> collapsed = Set<int>.from(state.collapsedSectionIndexes);
    if (!collapsed.remove(sectionIndex)) collapsed.add(sectionIndex);
    state = state.copyWith(collapsedSectionIndexes: collapsed);
  }

  void selectOption(int sectionIndex, int optionIndex) {
    state = state.copyWith(
      selectedOptionIndexes: <int, int>{
        ...state.selectedOptionIndexes,
        sectionIndex: optionIndex,
      },
    );
  }

  void _selectSectionAtTop(int sectionIndex) {
    if (sectionIndex == state.selectedSectionIndex) return;
    _selectAndExpandSection(sectionIndex);
  }

  void _selectAndExpandSection(int sectionIndex) {
    state = state.copyWith(
      selectedSectionIndex: sectionIndex,
      collapsedSectionIndexes: Set<int>.from(state.collapsedSectionIndexes)
        ..remove(sectionIndex),
    );
  }

  @override
  void dispose() {
    sectionsScrollSpy.dispose();
    super.dispose();
  }
}
