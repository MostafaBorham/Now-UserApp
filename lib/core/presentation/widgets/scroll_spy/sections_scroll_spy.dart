import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class SectionsScrollSpy {
  SectionsScrollSpy({required this.onSectionAtTop}) {
    scrollController.addListener(_reportSectionAtTop);
  }

  static const double _sectionAtTopTolerance = 1;

  final ValueChanged<int> onSectionAtTop;
  final ScrollController scrollController = ScrollController();
  final Map<int, GlobalKey> _sectionKeys = <int, GlobalKey>{};
  int _sectionScrollsInProgress = 0;

  GlobalKey sectionKey(int sectionIndex) =>
      _sectionKeys.putIfAbsent(sectionIndex, GlobalKey.new);

  Future<void> scrollToSection(int sectionIndex) async {
    final RenderObject? section = _attachedSection(_sectionKeys[sectionIndex]);
    if (section == null || !scrollController.hasClients) return;
    _sectionScrollsInProgress++;
    await scrollController.position.ensureVisible(
      section,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _sectionScrollsInProgress--;
  }

  void dispose() => scrollController.dispose();

  void _reportSectionAtTop() {
    if (_sectionScrollsInProgress > 0 || !scrollController.hasClients) return;
    final double topOffset =
        scrollController.position.pixels + _sectionAtTopTolerance;
    int? sectionAtTop;
    double sectionAtTopOffset = double.negativeInfinity;
    for (final MapEntry<int, GlobalKey> section in _sectionKeys.entries) {
      final double? sectionOffset = _sectionScrollOffset(section.value);
      if (sectionOffset == null ||
          sectionOffset > topOffset ||
          sectionOffset < sectionAtTopOffset) {
        continue;
      }
      sectionAtTop = section.key;
      sectionAtTopOffset = sectionOffset;
    }
    if (sectionAtTop != null) onSectionAtTop(sectionAtTop);
  }

  double? _sectionScrollOffset(GlobalKey sectionKey) {
    final RenderObject? section = _attachedSection(sectionKey);
    if (section == null) return null;
    return RenderAbstractViewport.maybeOf(
      section,
    )?.getOffsetToReveal(section, 0).offset;
  }

  RenderObject? _attachedSection(GlobalKey? sectionKey) {
    final RenderObject? section = sectionKey?.currentContext
        ?.findRenderObject();
    return section != null && section.attached ? section : null;
  }
}
