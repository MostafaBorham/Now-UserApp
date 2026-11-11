import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_type.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/circular_back_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/cart/circular_cart_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/favourites/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';

class DetailsTopBarButtons extends StatelessWidget {
  const DetailsTopBarButtons({
    super.key,
    required this.buttonSize,
    required this.favouriteType,
    this.favouriteState,
    this.favouriteItemId,
    this.onCartTap,
    this.showCloseButton = false,
  });

  final double buttonSize;
  final FavouriteType favouriteType;
  final AsyncValue<bool>? favouriteState;
  final int? favouriteItemId;
  final VoidCallback? onCartTap;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final AsyncValue<bool>? favouriteState = this.favouriteState;
    final BoxDecoration buttonDecoration = BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: colors.neutral200,
        strokeAlign: BorderSide.strokeAlignOutside,
      ),
      boxShadow: [
        BoxShadow(
          color: colors.neutral500.withValues(alpha: 0.12),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
    return Row(
      spacing: 8,
      children: [
        DecoratedBox(
          decoration: buttonDecoration,
          child: showCloseButton
              ? Material(
                  color: colors.white,
                  elevation: 3,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox.square(
                    dimension: 40,
                    child: CloseButton(
                      color: colors.black,
                      onPressed: () => context.pop(),
                    ),
                  ),
                )
              : CircularBackButton(size: buttonSize),
        ),
        const Spacer(),
        if (favouriteState != null)
          favouriteState.when(
            loading: () => AppShimmer(
              child: CircleAvatar(
                radius: buttonSize,
                backgroundColor: colors.white,
              ),
            ),
            error: (Object error, StackTrace stackTrace) =>
                const SizedBox.shrink(),
            data: (bool isFavourite) => DecoratedBox(
              decoration: buttonDecoration,
              child: CircularAppFavouriteIcon(
                size: buttonSize,
                elevation: 0,
                backgroundColor: colors.white,
                favouriteType: favouriteType,
                itemId: favouriteItemId,
                isFavourite: isFavourite,
              ),
            ),
          ),
        if (onCartTap != null)
          DecoratedBox(
            decoration: buttonDecoration,
            child: ReverseWidget(
              applyReverse: !context.isRTL,
              child: CircularCartButton(size: buttonSize, onTap: onCartTap),
            ),
          ),
      ],
    );
  }
}
