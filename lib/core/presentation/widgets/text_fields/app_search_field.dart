import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_box_shadows.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/recent_search_widget.dart';

class AppSearchField extends ConsumerStatefulWidget {
  const AppSearchField({
    super.key,
    this.hintText,
    this.autofocus = false,
    this.enableRecentKeywords = false,
    this.recentKeywords,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onRecentSelect,
    this.onRecentRemove,
    this.onRecentClear,
    this.recentClearLabel,
    this.hasFilter = false,
    this.onFilterTap,
    this.navigateToSearchOnTap = true,
  });

  final String? hintText;
  final bool autofocus;
  final bool? hasFilter;
  final bool navigateToSearchOnTap;
  final bool? enableRecentKeywords;
  final List<String>? recentKeywords;

  /// Optional external controller. When omitted, the field owns and disposes
  /// its own; provide one only when the parent needs to read/set the text.
  final TextEditingController? controller;

  /// Fired on every keystroke — used to filter the recent keywords live.
  final ValueChanged<String>? onChanged;

  /// Fired when the user submits the field (keyboard search/enter action).
  /// The field unfocuses itself before invoking this.
  final ValueChanged<String>? onSubmitted;

  final ValueChanged<String>? onRecentSelect;
  final ValueChanged<String>? onRecentRemove;
  final VoidCallback? onRecentClear;

  /// Label of the recents "remove them all" action. Defaults to
  /// [LangKeys.clearKey]; the address search passes [LangKeys.deleteKey].
  final String? recentClearLabel;
  final GestureTapCallback? onFilterTap;
  @override
  ConsumerState<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends ConsumerState<AppSearchField> {
  final FocusNode _focusNode = FocusNode();

  /// Falls back to an internally owned controller when the parent supplies none.
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && widget.navigateToSearchOnTap) {
      _focusNode.unfocus();
      context.pushNamed(AppRoutes.searchScreen);
      return;
    }
    setState(() {});
  }

  /// Puts the picked keyword into the field and dismisses the recents view by
  /// unfocusing (req 4). The parent callback still fires for any extra handling.
  void _onRecentSelect(String term) {
    _controller
      ..text = term
      ..selection = TextSelection.collapsed(offset: term.length);
    _focusNode.unfocus();
    widget.onRecentSelect?.call(term);
  }

  /// Unfocuses before handing the submitted term to the parent (req 6).
  void _onSubmitted(String value) {
    _focusNode.unfocus();
    widget.onSubmitted?.call(value);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    // Only dispose the controller we created ourselves.
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final List<String> keywords = widget.recentKeywords ?? const <String>[];
    final bool showRecent =
        (widget.enableRecentKeywords ?? false) &&
        _focusNode.hasFocus &&
        keywords.isNotEmpty;

    return TapRegion(
      onTapOutside: (PointerDownEvent event) {
        if (_focusNode.hasFocus) _focusNode.unfocus();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 7.5,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints con) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: colors.onPrimary,
                    borderRadius: AppBorderRadius.brCircular30,
                    boxShadow: AppBoxShadows.blackBottomShadow1,
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Builder(
                          builder: (BuildContext context) {
                            final Widget field = Center(
                              child: TextFormField(
                                controller: _controller,
                                onChanged: widget.onChanged,
                                onFieldSubmitted: _onSubmitted,
                                textInputAction: TextInputAction.search,
                                style: AppTextStyles.style16Regular.copyWith(
                                  color: colors.onSecondary,
                                  fontSize: con.maxWidth * 0.05,
                                ),
                                textAlignVertical: TextAlignVertical.center,
                                autofocus: widget.autofocus,
                                focusNode: _focusNode,
                                readOnly: widget.navigateToSearchOnTap,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText:
                                      widget.hintText ??
                                      LangKeys.searchNowKey.tr(),
                                  hintStyle: AppTextStyles.style16Regular
                                      .copyWith(
                                        color: colors.onPrimaryFixed,
                                        fontSize: con.maxWidth * 0.05,
                                      ),
                                  prefixIcon: ReverseWidget(
                                    applyReverse: context.isRTL,
                                    child: Assets.media.images.svg.searchIcon
                                        .svg(),
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                    maxHeight: con.maxWidth * 0.05,
                                    minWidth: con.maxWidth * 0.05,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            );
                            if (!widget.navigateToSearchOnTap) return field;
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () =>
                                  context.pushNamed(AppRoutes.searchScreen),
                              child: field,
                            );
                          },
                        ),
                      ),
                      if (widget.hasFilter ?? false)
                        InkWell(
                          onTap: widget.onFilterTap,
                          borderRadius: AppBorderRadius.brCircular30,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 8,
                            ),
                            child: Assets.media.images.svg.filterIcon.svg(
                              colorFilter: ColorFilter.mode(
                                colors.onSecondary,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: showRecent
                ? Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: RecentSearchWidget(
                      keywords: keywords,
                      clearLabel: widget.recentClearLabel,
                      onSelect: _onRecentSelect,
                      onRemove: widget.onRecentRemove,
                      onClear: widget.onRecentClear,
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
