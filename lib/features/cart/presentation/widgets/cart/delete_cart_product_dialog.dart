import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/delete_cart_product_vm.dart';
import 'package:nowdelivery_user_app/features/cart/viewmodel/get_cart_vm.dart';

/// Confirmation + progress dialog for removing a single cart line.
///
/// Lifecycle inside the one dialog:
///   1. Confirm  – asks the user to confirm the deletion (Cancel / Delete).
///   2. Loading  – once confirmed, fires [UpdateCartProductViewModel] and shows
///      a spinner; the dialog can NOT be dismissed (barrier + back button).
///   3. Result   – on success the dialog closes and the line is removed from
///      [getCartProvider]'s state locally (no refetch); on failure the spinner
///      stops, the dialog stays open (back on the confirm state) and an error
///      snackbar is shown.
///
/// Open it with `barrierDismissible: false` so the loading state is truly
/// non-dismissible; cancelling is only possible through the Cancel button.
class DeleteCartProductDialog extends ConsumerStatefulWidget {
  const DeleteCartProductDialog({
    super.key,
    required this.productId,
    required this.productName,
  });

  final int productId;
  final String productName;

  @override
  ConsumerState<DeleteCartProductDialog> createState() =>
      _DeleteCartProductDialogState();
}

class _DeleteCartProductDialogState
    extends ConsumerState<DeleteCartProductDialog> {
  bool _isDeleting = false;

  void _confirmDelete() {
    setState(() => _isDeleting = true);
    ref
        .read(deleteCartProductProvider(widget.productId).notifier)
        .deleteCartProduct();
  }

  void _handleResult(AsyncValue<CartModel?> state) {
    state.whenOrNull(
      data: (CartModel? cart) {
        if (cart == null) return;
        Navigator.of(context).pop();
        ref.read(getCartProvider.notifier).updateCartState(cart);
      },
      error: (Object error, StackTrace _) {
        // Stop loading but keep the dialog open, then surface the error.
        setState(() => _isDeleting = false);

        final ColorScheme colors = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                error.toString().tr(),
                style: AppTextStyles.style16SemiBold.copyWith(
                  color: colors.onPrimary,
                ),
              ),
              behavior: SnackBarBehavior.floating,
              elevation: 4,
              padding: const EdgeInsets.all(16),
              backgroundColor: colors.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    ref.listen<AsyncValue<CartModel?>>(
      deleteCartProductProvider(widget.productId),
      (AsyncValue<CartModel?>? previous, AsyncValue<CartModel?> next) =>
          _handleResult(next),
    );

    // While deleting the dialog must not be dismissible in any way.
    return PopScope(
      canPop: !_isDeleting,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: AspectRatio(
          aspectRatio: 2,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.onPrimary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Remove Product',
                  style: AppTextStyles.style16SemiBold.copyWith(
                    color: colors.tertiaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Text(
                    'Are you sure you want to remove ${widget.productName} from your cart?',
                    maxLines: 3,
                    style: AppTextStyles.style14Regular.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel is dimmed and disabled while a deletion is running.
                    TextButton(
                      onPressed: _isDeleting
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.style14Medium.copyWith(
                          color: colors.onSurface.withValues(
                            alpha: _isDeleting ? 0.4 : 1,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _isDeleting ? null : _confirmDelete,
                      // Fixed slot so the spinner and the label share the same
                      // width — Cancel never shifts when toggling states.
                      child: SizedBox(
                        width: 64,
                        child: Center(
                          child: _isDeleting
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.onError,
                                  ),
                                )
                              : Text(
                                  'Delete',
                                  style: AppTextStyles.style14Medium.copyWith(
                                    color: colors.onError,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
