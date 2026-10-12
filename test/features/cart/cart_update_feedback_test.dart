import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/cart_update_feedback.dart';

void main() {
  // A change to a line that is already in the cart has to say what it did:
  // reducing or clearing it used to confirm with "added to cart".
  group('cartUpdateMessageKey', () {
    // The first add used to open a sheet; it is a toast like the rest now.
    test('a first add reads as an add', () {
      expect(
        cartUpdateMessageKey(previousQuantity: 0, quantity: 1),
        LangKeys.productAddedToCartKey,
      );
    });

    test('a cleared line reads as a removal', () {
      expect(
        cartUpdateMessageKey(previousQuantity: 1, quantity: 0),
        LangKeys.productRemovedFromCartKey,
      );
    });

    test('a dropped unit reads as a quantity update', () {
      expect(
        cartUpdateMessageKey(previousQuantity: 3, quantity: 2),
        LangKeys.cartQuantityUpdatedKey,
      );
    });

    test('an extra unit still reads as an add', () {
      expect(
        cartUpdateMessageKey(previousQuantity: 2, quantity: 3),
        LangKeys.productAddedToCartKey,
      );
    });
  });
}
