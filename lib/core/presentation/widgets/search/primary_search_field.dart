import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/recent_search_widget.dart';

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




  final VoidCallback? onTap;


  final ValueChanged<String>? onSearch;




  final ValueChanged<String>? onChanged;



  final ValueChanged<String>? onSubmitted;




  final TextEditingController? controller;




  final bool isAnimated;






  final bool enableRecentKeywords;
  final List<String>? recentKeywords;
  final ValueChanged<String>? onRecentSelect;
  final ValueChanged<String>? onRecentRemove;
  final VoidCallback? onRecentClear;
  final String? recentClearLabel;


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

  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  bool get _isEditable => widget.onTap == null;

  @override
  void initState() {
    super.initState();

    if (widget.enableRecentKeywords) {
      _focusNode.addListener(_onFocusChange);
    }
  }

  void _onFocusChange() => setState(() {});

  void _onChanged(String value) {

    widget.onChanged?.call(value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      widget.onSearch?.call(value);
    });
  }


  void _onSubmitted(String value) {
    _focusNode.unfocus();
    widget.onSubmitted?.call(value);
  }



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
                          onSubmitted: _onSubmitted,
                          textInputAction: TextInputAction.search,
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
                        )
                      : widget.isAnimated
                      ? _AnimatedSearchHint(
                          hints: hints,
                          style: hintStyle,
                        )
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
                    colorFilter: ColorFilter.mode(colors.white, BlendMode.srcIn),
                  ),
                ),
              ],
            ),
          );
        }
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





          Flexible(
            child: _CollapsibleRecents(
              show: showRecent,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),


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
      child = TapRegion(
        onTapOutside: (_) => _focusNode.unfocus(),
        child: child,
      );
    }

    return child;
  }
}









class _AnimatedSearchHint extends StatefulWidget {
  const _AnimatedSearchHint({
    required this.hints,
    required this.style,
  });

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
      _timer = Timer.periodic(_dwell, (Timer _) => _controller.forward(from: 0));
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {


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

                FractionalTranslation(
                  translation: Offset(0, -t),
                  child: _line(_current),
                ),

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
