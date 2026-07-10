import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
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
    this.reverseSearchIcon = false,
    this.autofocus = false,
    this.enableRecentKeywords = false,
    this.recentKeywords,
    this.onRecentSelect,
    this.onRecentRemove,
    this.onRecentClear,
  });

  final String? hintText;
  final bool? reverseSearchIcon;
  final bool autofocus;
  final bool? enableRecentKeywords;
  final List<String>? recentKeywords;
  final ValueChanged<String>? onRecentSelect;
  final ValueChanged<String>? onRecentRemove;
  final VoidCallback? onRecentClear;

  @override
  ConsumerState<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends ConsumerState<AppSearchField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final List<String> keywords = widget.recentKeywords ?? const <String>[];
    final bool showRecent = (widget.enableRecentKeywords ?? false) &&
        _focusNode.hasFocus &&
        keywords.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 7.5,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints con) {
              return Container(
                decoration: BoxDecoration(
                  color: colors.onPrimary,
                  borderRadius: AppBorderRadius.brCircular30,
                  boxShadow: AppBoxShadows.blackBottomShadow1,
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.pushNamed(AppRoutes.searchScreen,
                  ),
                  child: AbsorbPointer(
                    // absorbing: widget.onTap != null,
                    child: Center(
                      child: TextFormField(
                        style: AppTextStyles.style16Regular.copyWith(
                          color: colors.onSecondary,
                          fontSize: con.maxWidth * 0.05,
                        ),
                        autofocus: widget.autofocus,
                        focusNode: _focusNode,
                        // readOnly: widget.onTap != null,
                        decoration: InputDecoration(
                          hintText:
                              widget.hintText ?? LangKeys.searchNowKey.tr(),
                          hintStyle: AppTextStyles.style16Regular.copyWith(
                            color: colors.onPrimaryFixed,
                            fontSize: con.maxWidth * 0.05,
                          ),
                          prefixIcon: Padding(
                            padding:
                                const EdgeInsetsDirectional.only(start: 16),
                            child: ReverseWidget(
                              applyReverse: widget.reverseSearchIcon,
                              child: Assets.media.images.svg.searchIcon.svg(),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            maxHeight: 25,
                            minWidth: 25,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(8),
                        ),
                      ),
                    ),
                  ),
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
                    onSelect: widget.onRecentSelect,
                    onRemove: widget.onRecentRemove,
                    onClear: widget.onRecentClear,
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
