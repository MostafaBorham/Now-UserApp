


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_type.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/utils/auth_guard.dart';
import 'package:nowdelivery_user_app/features/favourites/viewmodel/product/product_favourite_vm.dart';
import 'package:nowdelivery_user_app/features/favourites/viewmodel/store/store_favourite_vm.dart';














class CircularAppFavouriteIcon extends ConsumerStatefulWidget {
  const CircularAppFavouriteIcon({
    super.key,
    this.size = 20,
    this.isFavourite = false,
    this.favouriteType,
    this.itemId,
    this.onFavouriteChanged,
  });

  final double? size;


  final bool? isFavourite;


  final FavouriteType? favouriteType;



  final int? itemId;



  final ValueChanged<bool>? onFavouriteChanged;

  @override
  ConsumerState<CircularAppFavouriteIcon> createState() =>
      _CircularAppFavouriteIconState();
}

class _CircularAppFavouriteIconState
    extends ConsumerState<CircularAppFavouriteIcon> {



  late bool _isFavourite = widget.isFavourite ?? false;

  bool get _isIntegrated =>
      widget.favouriteType != null && widget.itemId != null;




  ({int productId, bool isFavourite}) get _productArgs =>
      (productId: widget.itemId!, isFavourite: widget.isFavourite ?? false);

  ({int storeId, bool isFavourite}) get _storeArgs =>
      (storeId: widget.itemId!, isFavourite: widget.isFavourite ?? false);

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    AsyncValue<bool> state = AsyncValue<bool>.data(_isFavourite);

    if (_isIntegrated) {
      if (widget.favouriteType == FavouriteType.product) {
        final provider = productFavouriteProvider(_productArgs);
        ref.listen(provider, _onStateChanged);
        state = ref.watch(provider);
      } else {
        final provider = storeFavouriteProvider(_storeArgs);
        ref.listen(provider, _onStateChanged);
        state = ref.watch(provider);
      }
    }


    final bool isFavourite = state.valueOrNull ?? _isFavourite;

    return InkWell(
      overlayColor: WidgetStateColor.resolveWith(
        (states) => Colors.transparent,
      ),
      onTap: () {
        if (!state.isLoading) _onTap(isFavourite);
      },
      child: Material(
        elevation: 1,
        color: colors.white.withValues(alpha: 0.6),
        shape: const CircleBorder(),
        child: CircleAvatar(
          radius: widget.size,
          backgroundColor: colors.white.withValues(alpha: 0.6),
          child: state.isLoading
              ? SizedBox.square(
                  dimension: widget.size,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.errorContainer,
                  ),
                )
              : (isFavourite
                        ? Assets.media.images.svg.filledFavouriteIcon
                        : Assets.media.images.svg.favouriteIcon)
                    .svg(
                      width: widget.size,
                      colorFilter: ColorFilter.mode(
                        isFavourite
                            ? colors.errorContainer
                            : colors.neutral1200,
                        BlendMode.srcIn,
                      ),
                    ),
        ),
      ),
    );
  }



  void _onStateChanged(AsyncValue<bool>? previous, AsyncValue<bool> next) {
    next.whenOrNull(
      data: (bool isFavourite) {
        if (isFavourite == _isFavourite) return;

        setState(() => _isFavourite = isFavourite);
        widget.onFavouriteChanged?.call(isFavourite);
      },
      error: (Object error, _) => AppToast.showError(context, error.toString()),
    );
  }

  void _onTap(bool isFavourite) {
    if (redirectGuestToLogin(context)) return;

    if (!_isIntegrated) {
      setState(() => _isFavourite = !isFavourite);
      widget.onFavouriteChanged?.call(_isFavourite);
      return;
    }

    if (widget.favouriteType == FavouriteType.product) {
      final ProductFavouriteViewModel notifier = ref.read(
        productFavouriteProvider(_productArgs).notifier,
      );

      isFavourite
          ? notifier.removeFromFavourites()
          : notifier.addToFavourites();
      return;
    }

    final StoreFavouriteViewModel notifier = ref.read(
      storeFavouriteProvider(_storeArgs).notifier,
    );

    isFavourite ? notifier.removeFromFavourites() : notifier.addToFavourites();
  }
}
