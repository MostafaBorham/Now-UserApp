import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class PrimarySearchField extends StatefulWidget {
  const PrimarySearchField({
    super.key,
    this.onTap,
    this.onSearch,
    this.suggestions,
  });

  /// Fired when the bar is tapped. When non-null the field is read-only and
  /// acts as a tap target (e.g. to navigate to a search screen). When null the
  /// field becomes editable and shows the keyboard on tap.
  final VoidCallback? onTap;

  /// Debounced search callback — fires 1 second after the user stops typing.
  final ValueChanged<String>? onSearch;

  /// Localization keys cycled through as the animated placeholder. Defaults to
  /// the app's generic search phrases.
  final List<String>? suggestions;

  static const List<String> _defaultSuggestions = <String>[
    LangKeys.searchNowKey,
    LangKeys.searchForAProductKey,
    LangKeys.searchForAStoreKey,
    LangKeys.searchForBrandKey,
  ];

  @override
  State<PrimarySearchField> createState() => _PrimarySearchFieldState();
}

class _PrimarySearchFieldState extends State<PrimarySearchField> {
  late final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  bool get _isEditable => widget.onTap == null;

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      widget.onSearch?.call(value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final List<String> suggestions =
        widget.suggestions ?? PrimarySearchField._defaultSuggestions;
    final TextStyle hintStyle = AppTextStyles.style16Regular.copyWith(
      color: colors.onPrimaryFixed,
    );

    Widget child = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _isEditable ? null : widget.onTap,
      child: LayoutBuilder(
        builder: (context,con) {
          return Container(
            padding: EdgeInsetsDirectional.only(
              start: 16,
              end: 8,
              top: con.maxWidth*0.02,
              bottom: con.maxWidth*0.02,
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
                      ? TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          onChanged: _onChanged,
                          textInputAction: TextInputAction.search,
                          style: AppTextStyles.style16Regular.copyWith(
                            color: colors.black,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText: suggestions.first.tr(),
                            hintStyle: hintStyle,
                          ),
                        )
                      : _AnimatedSearchHint(
                          suggestions: suggestions,
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
                    colorFilter: ColorFilter.mode(colors.white, BlendMode.srcIn),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );

    if (_isEditable) {
      child = TapRegion(
        onTapOutside: (_) => _focusNode.unfocus(),
        child: child,
      );
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
  const _AnimatedSearchHint({
    required this.suggestions,
    required this.style,
  });

  final List<String> suggestions;
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

  bool get _cycles => widget.suggestions.length > 1;

  int get _next => (_current + 1) % widget.suggestions.length;

  @override
  void initState() {
    super.initState();
    if (_cycles) {
      _controller.addStatusListener(_onStatus);
      _timer = Timer.periodic(_dwell, (Timer _) => _controller.forward(from: 0));
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
      widget.suggestions[index].tr(),
      maxLines: 1,
      textAlign: TextAlign.start,
      style: widget.style,
    );
  }
}
