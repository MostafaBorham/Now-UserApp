import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

/// Retry affordance for a page of a list that failed to load, sized to sit at
/// the end of an existing list instead of replacing it — the items already on
/// screen stay, this only reports that the *next* page did not arrive.
///
/// Use [ServerConnectionErrorWidget] instead when the first page failed and
/// there is nothing to show.
class NextPageErrorWidget extends StatelessWidget {
  const NextPageErrorWidget({
    super.key,
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Center(
      child: IconButton(
        onPressed: onRetry,
        tooltip: LangKeys.retryKey.tr(),
        iconSize: 40,
        icon: Assets.media.images.svg.retryIcon.svg(
          width: 40,
          colorFilter: ColorFilter.mode(colors.onError, BlendMode.srcIn),
        ),
      ),
    );
  }
}
