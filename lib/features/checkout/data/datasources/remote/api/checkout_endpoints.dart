/// API endpoints owned by the checkout feature.
abstract class CheckoutEndpoints {
  /// Prepares a draft order group. The same endpoint backs both flows:
  /// - a `null` `vendor_id` drafts every store in the cart,
  /// - a concrete `vendor_id` drafts only that single store.
  static const String checkout = '/api/v1/checkout/draft';

  /// Builds the draft request body. [vendorId] is `null` for the all-stores
  /// flow and a store id for the single-store flow; either way the key is sent
  /// so the server can distinguish the two cases explicitly.
  static Map<String, dynamic> checkoutBody({int? vendorId}) => <String, dynamic>{
        'vendor_id': vendorId,
      };
}
