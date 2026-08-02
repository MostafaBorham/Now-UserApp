/// API endpoints owned by the address feature.
abstract class AddressEndpoints {
  static const String addresses = '/api/v1/addresses';
  static const String defaultAddress = '/api/v1/addresses/default';

  static String setDefaultAddress(int addressId) =>
      '/api/v1/addresses/$addressId/set-default';
}
