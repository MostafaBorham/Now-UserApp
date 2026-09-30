import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/cart/cart_badge.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';

class CircularCartButton extends ConsumerWidget {
  const CircularCartButton({super.key, this.size, this.onTap});
  final double? size;

  final GestureTapCallback? onTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    // Same count as the bottom-nav cart badge (see MainScreen).
    final int cartItemCount = ref.watch(
      getCartProvider.select(
        (AsyncValue<CartModel> state) => state.valueOrNull?.itemCount ?? 0,
      ),
    );
    return InkWell(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            backgroundColor: colors.white,
            radius: size??25,
            child: Center(
              // Only the icon mirrors in RTL — the badge's digits must not.
              child: ReverseWidget(
                child: Assets.media.images.svg.shoppingCartIcon.svg(
                  fit: BoxFit.contain,
                  width: size??25,
                  colorFilter: ColorFilter.mode(
                    colors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          if (cartItemCount > 0)
            PositionedDirectional(
              top: -4,
              end: -4,
              child: CartBadge(count: cartItemCount),
            ),
        ],
      ),
    );
  }
}
