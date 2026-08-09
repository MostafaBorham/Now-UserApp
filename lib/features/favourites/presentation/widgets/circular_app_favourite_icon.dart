import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/caching/token_cache_service.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_type.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/favourites/viewmodel/product/product_favourite_vm.dart';
import 'package:nowdelivery_user_app/features/favourites/viewmodel/store/store_favourite_vm.dart';

/// Circular favourite (heart) button.
///
/// Pass [favouriteType] together with [itemId] to wire the icon to the matching
/// favourite viewmodel — [FavouriteType.product] watches
/// `productFavouriteProvider`, [FavouriteType.store] watches
/// `storeFavouriteProvider`, both seeded with [isFavourite]. Tapping then calls
/// remove when the item is already favourited and add when it is not; the icon
/// is replaced by a spinner while the request is in flight, and a failure only
/// shows a snackbar — the displayed status stays where it was.
///
/// With either of them left `null` the icon keeps its offline behaviour: it just
/// flips locally and reports through [onFavouriteChanged] (used by the screens
/// that are still on mock data).
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

  /// Initial favourite status, and the seed of the viewmodel's state.
  final bool? isFavourite;

  /// Which favourite provider to drive. `null` disables backend integration.
  final FavouriteType? favouriteType;

  /// Product id or store id, depending on [favouriteType]. `null` disables
  /// backend integration.
  final int? itemId;

  /// Called with the new status every time it actually changes — after a
  /// successful request when integrated, on tap otherwise.
  final ValueChanged<bool>? onFavouriteChanged;

  @override
  ConsumerState<CircularAppFavouriteIcon> createState() =>
      _CircularAppFavouriteIconState();
}

class _CircularAppFavouriteIconState
    extends ConsumerState<CircularAppFavouriteIcon> {
  /// Last status the icon is allowed to show. Kept next to the provider because
  /// `AsyncValue.loading()` / `AsyncValue.error()` carry no value, so this is
  /// what the icon falls back to while a request runs or after it failed.
  late bool _isFavourite = widget.isFavourite ?? false;

  bool get _isIntegrated =>
      widget.favouriteType != null && widget.itemId != null;

  /// Family arguments, built from [CircularAppFavouriteIcon.isFavourite] rather
  /// than [_isFavourite] so the widget keeps watching the same provider
  /// instance across toggles.
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

    // Loading and error hold no value, so both keep showing the last status.
    final bool isFavourite = state.valueOrNull ?? _isFavourite;

    return InkWell(
      overlayColor: WidgetStateColor.resolveWith((states) => Colors.transparent,),
      onTap: () {
        if(!state.isLoading)_onTap(isFavourite);
      },
      child: Material(
        elevation: 1,
        shape: const CircleBorder(),
        child: CircleAvatar(
          radius: widget.size,
          backgroundColor: colors.white,
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

  /// Mirrors a settled request into [_isFavourite]: a success becomes the new
  /// status, a failure only surfaces its message.
  void _onStateChanged(AsyncValue<bool>? previous, AsyncValue<bool> next) {
    next.whenOrNull(
      data: (bool isFavourite) {
        if (isFavourite == _isFavourite) return;

        setState(() => _isFavourite = isFavourite);
        widget.onFavouriteChanged?.call(isFavourite);
      },
      error: (Object error, _) => ErrorSnackBar.show(context, error.toString()),
    );
  }

  void _onTap(bool isFavourite) {
    if (_redirectedToLogin()) return;

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

  /// Sends guests to phone verification instead of favouriting. Returns whether
  /// the tap was consumed by that redirect.
  bool _redirectedToLogin() {
    if (!TokenCacheService().hasAccessToken) {
      context.pushNamed(AppRoutes.phoneVerificationScreen);
      return true;
    }

    return false;
  }
}
