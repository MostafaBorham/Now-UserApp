import 'dart:async';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/recent_search_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/svg_tint.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/input_direction.dart';

class PrimarySearchField extends StatefulWidget {
  const PrimarySearchField({
    super.key,
    this.onTap,
    this.onSearch,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.isAnimated = true,
    this.enableRecentKeywords = false,
    this.recentKeywords,
    this.onRecentSelect,
    this.onRecentRemove,
    this.onRecentClear,
    this.recentClearLabel,
  });

  /// Fired when the bar is tapped. When non-null the field is read-only and
  /// acts as a tap target (e.g. to navigate to a search screen). When null the
  /// field becomes editable and shows the keyboard on tap.
  final VoidCallback? onTap;

  /// Debounced search callback — fires 1 second after the user stops typing.
  final ValueChanged<String>? onSearch;

  /// Fired on every keystroke, unbounced — lets the parent react immediately
  /// (e.g. toggle a recents panel the moment the field goes empty / non-empty)
  /// without waiting on the debounce.
  final ValueChanged<String>? onChanged;

  /// Fired when the field is submitted from the keyboard; the field unfocuses
  /// itself first.
  final ValueChanged<String>? onSubmitted;

  /// Optional external controller (editable mode). Provide one when the parent
  /// needs to read or set the text — e.g. to fill it from a picked recent. When
  /// omitted the field owns and disposes its own.
  final TextEditingController? controller;

  /// When `true` (default) the read-only hint cycles through [_hints] with a
  /// rising animation. When `false` no animation is created at all — the hint
  /// is a plain static line showing only the first hint.
  final bool isAnimated;

  /// Recent keywords shown under the field while it is focused (editable mode).
  /// Pass an empty list to hide them — e.g. once the user starts typing. The
  /// recents panel is scrollable and fills the height it is given, so the field
  /// must be laid out with a bounded height (wrap it in [Flexible]/[Expanded])
  /// whenever this is enabled.
  final bool enableRecentKeywords;
  final List<String>? recentKeywords;
  final ValueChanged<String>? onRecentSelect;
  final ValueChanged<String>? onRecentRemove;
  final VoidCallback? onRecentClear;
  final String? recentClearLabel;

  /// Localization keys used as the placeholder hints.
  static const List<String> _hints = <String>[
    LangKeys.searchHintKey,
    LangKeys.searchForAProductKey,
    LangKeys.searchForAStoreKey,
    LangKeys.searchForBrandKey,
  ];

  @override
  State<PrimarySearchField> createState() => _PrimarySearchFieldState();
}

class _PrimarySearchFieldState extends State<PrimarySearchField> {
  /// Falls back to an internally owned controller when the parent supplies none.
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  bool get _isEditable => widget.onTap == null;

  @override
  void initState() {
    super.initState();
    // Only needed to show / hide the recents as focus changes.
    if (widget.enableRecentKeywords) {
      _focusNode.addListener(_onFocusChange);
    }
  }

  void _onFocusChange() => setState(() {});

  void _onChanged(String value) {
    // Unbounced: lets the parent react the instant typing starts / stops.
    widget.onChanged?.call(value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      widget.onSearch?.call(value);
    });
  }

  /// Unfocuses before handing the submitted term to the parent.
  void _onSubmitted(String value) {
    _focusNode.unfocus();
    widget.onSubmitted?.call(value);
  }

  /// Puts the picked keyword into the field and dismisses the recents by
  /// unfocusing, then lets the parent run the search for it.
  void _onRecentSelect(String term) {
    _debounce?.cancel();
    _controller
      ..text = term
      ..selection = TextSelection.collapsed(offset: term.length);
    _focusNode.unfocus();
    widget.onRecentSelect?.call(term);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    // Only dispose the controller we created ourselves.
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    const List<String> hints = PrimarySearchField._hints;
    final TextStyle hintStyle = AppTextStyles.style16Regular.copyWith(
      color: colors.onPrimaryFixed,
    );

    Widget child = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _isEditable ? null : widget.onTap,
      child: LayoutBuilder(
        builder: (context, con) {
          return Container(
            padding: EdgeInsetsDirectional.only(
              start: 16,
              end: 8,
              top: con.maxWidth * 0.02,
              bottom: con.maxWidth * 0.02,
            ),
            decoration: BoxDecoration(
              color: colors.white,
              borderRadius: AppBorderRadius.brCircular8,
              border: Border.all(color: colors.primary500Main),
            ),
            child: Row(
              spacing: 8,
              children: <Widget>[
                Expanded(
                  child: _isEditable
                      ? InputDirectionBuilder(
                          controller: _controller,
                          builder:
                              (
                                BuildContext context,
                                TextDirection? typedDirection,
                              ) => TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                onChanged: _onChanged,
                                onSubmitted: _onSubmitted,
                                textInputAction: TextInputAction.search,
                                textDirection: typedDirection,
                                style: AppTextStyles.style16Regular.copyWith(
                                  color: colors.black,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: hints.first.tr(),
                                  hintStyle: hintStyle,
                                ),
                              ),
                        )
                      : widget.isAnimated
                      ? _AnimatedSearchHint(hints: hints, style: hintStyle)
                      : Text(
                          hints.first.tr(),
                          maxLines: 1,
                          textAlign: TextAlign.start,
                          style: hintStyle,
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colors.primary500Main,
                    borderRadius: AppBorderRadius.brCircular16,
                  ),
                  child: Assets.media.images.svg.searchNormalIcon.svg(
                    width: 16,
                    height: 16,
                    colorMapper: SvgTint(colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    if (_isEditable && widget.enableRecentKeywords) {
      final List<String> keywords = widget.recentKeywords ?? const <String>[];
      final bool showRecent = _focusNode.hasFocus && keywords.isNotEmpty;
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          child,
          // Fills the height the field is given below its box and scrolls, so a
          // long recents list never overflows or pushes the rest off-screen.
          // The fold/fade opens and closes as focus toggles the panel; fully
          // collapsed it takes no height, so the categories sit right under the
          // field exactly as before.
          Flexible(
            child: _CollapsibleRecents(
              show: showRecent,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                // No keyboard-dismiss on drag: scrolling the recents must keep
                // the field focused so the panel stays open while browsing.
                child: SingleChildScrollView(
                  child: RecentSearchWidget(
                    keywords: keywords,
                    clearLabel: widget.recentClearLabel,
                    onSelect: _onRecentSelect,
                    onRemove: widget.onRecentRemove,
                    onClear: widget.onRecentClear,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_isEditable) {
      // Taps on the recents panel count as inside the field, so the app-wide
      // tap-outside unfocus leaves it open.
      child = TextFieldTapRegion(child: child);
    }

    return child;
  }
}

/// A vertically-scrolling placeholder that rises: the current phrase slides up
/// and out through the top while the next enters from the bottom.
///
/// Performance notes: a single [AnimationController] runs only during the
/// ~500ms transition and stays completely idle (no ticks) during the dwell,
/// which is timed by one cheap [Timer]. Movement uses [FractionalTranslation]
/// (a plain transform, no `saveLayer`) clipped by [ClipRect], and the whole
/// thing sits behind a [RepaintBoundary] so it never repaints the page.
class _AnimatedSearchHint extends StatefulWidget {
  const _AnimatedSearchHint({required this.hints, required this.style});

  final List<String> hints;
  final TextStyle style;

  @override
  State<_AnimatedSearchHint> createState() => _AnimatedSearchHintState();
}

class _AnimatedSearchHintState extends State<_AnimatedSearchHint>
    with SingleTickerProviderStateMixin {
  static const Duration _dwell = Duration(seconds: 3);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  Timer? _timer;
  int _current = 0;

  bool get _cycles => widget.hints.length > 1;

  int get _next => (_current + 1) % widget.hints.length;

  @override
  void initState() {
    super.initState();
    if (_cycles) {
      _controller.addStatusListener(_onStatus);
      _timer = Timer.periodic(
        _dwell,
        (Timer _) => _controller.forward(from: 0),
      );
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // Adopt the incoming phrase as the resting one, then snap back to the
      // steady state. Setting value fires a single rebuild — no full setState.
      _current = _next;
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (BuildContext context, Widget? _) {
            final double t = _animation.value;
            return Stack(
              alignment: AlignmentDirectional.centerStart,
              children: <Widget>[
                // Resting / outgoing phrase: rises from center to the top.
                FractionalTranslation(
                  translation: Offset(0, -t),
                  child: _line(_current),
                ),
                // Incoming phrase: only built while a transition is running.
                if (t > 0)
                  FractionalTranslation(
                    translation: Offset(0, 1 - t),
                    child: _line(_next),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _line(int index) {
    return Text(
      widget.hints[index].tr(),
      maxLines: 1,
      textAlign: TextAlign.start,
      style: widget.style,
    );
  }
}

/// Opens and closes the recents panel with a fold (from the top) and a fade as
/// [show] toggles. At rest it stays in the tree at zero height, so the layout
/// slot is identical to the panel being absent — no jump when it collapses.
class _CollapsibleRecents extends StatefulWidget {
  const _CollapsibleRecents({required this.show, required this.child});

  final bool show;
  final Widget child;

  @override
  State<_CollapsibleRecents> createState() => _CollapsibleRecentsState();
}

class _CollapsibleRecentsState extends State<_CollapsibleRecents>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
    value: widget.show ? 1 : 0,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void didUpdateWidget(covariant _CollapsibleRecents oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show != oldWidget.show) {
      widget.show ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SizeTransition(
        alignment: AlignmentDirectional.topStart,
        sizeFactor: _animation,
        child: widget.child,
      ),
    );
  }
}
