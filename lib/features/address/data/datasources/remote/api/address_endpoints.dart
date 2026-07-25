/// API endpoints owned by the address feature.
abstract class AddressEndpoints {
  static const String getMyAddresses = '/api/v1/addresses';

  static String setDefaultAddress(int addressId) =>
      '/api/v1/addresses/$addressId/set-default';
}
