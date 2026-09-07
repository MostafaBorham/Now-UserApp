import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// Empty state for the addresses screen: a large home-location illustration
/// with a caption below it.
///
/// Scrollable so it still fills the list area and keeps pull-to-refresh working
/// when there are no addresses to scroll.
class NoAddressesView extends StatelessWidget {
  const NoAddressesView({super.key});

  /// The illustration takes half the screen width; its height follows the
  /// asset's own aspect ratio.
  static const double _iconWidthFactor = 0.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Assets.media.images.svg.homeLocationIcon.svg(
                  width: MediaQuery.sizeOf(context).width * _iconWidthFactor,
                ),
                const SizedBox(height: 20),
                Text(
                  LangKeys.noSavedAddresses.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.style24SemiBold.copyWith(
                    color: context.colors.tertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
