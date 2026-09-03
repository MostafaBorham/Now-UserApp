import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart/welcome_voucher_banner.dart';
import 'package:nowdelivery_user_app/features/main/presentation/controllers/main_tab_index_provider.dart';

class CartEmptyView extends ConsumerWidget {
  const CartEmptyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    return LayoutBuilder(
      builder: (context, con) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: con.maxHeight),
            child: Column(
              spacing: 10,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AspectRatio(
                    aspectRatio: 2,
                    child: Assets.media.images.svg.emptyCartImg.svg()),
                const WelcomeVoucherBanner(),
                Text(
                  LangKeys.cartEmptyTitleKey.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: con.maxWidth * 0.06,
                    color: colors.black,
                  ),
                ),
                Text(
                  LangKeys.cartEmptySubtitleKey.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: con.maxWidth * 0.04,
                  ),
                ),
                AspectRatio(
                  aspectRatio: 7,
                  child: PrimaryAppButton(
                    title: LangKeys.browseProductsKey.tr(),
                    buttonPadding: 10,
                    onTap: () {
                      ref.read(mainTabIndexProvider.notifier).state = 0;
                      context.goNamed(AppRoutes.mainScreen);
                    },
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
