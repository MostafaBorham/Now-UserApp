/// API endpoints owned by the address feature.
abstract class AddressEndpoints {
  static const int _perPage = 15;

  static const String addresses = '/api/v1/addresses';
  static const String defaultAddress = '/api/v1/addresses/default';

  /// Query parameters for `getMyAddresses`. A pure function of [page] — no
  /// shared mutable state, so two callers can never clobber each other's page.
  static Map<String, dynamic> myAddressesQuery(int page) => <String, dynamic>{
    'per_page': _perPage,
    'page': page,
  };

  static String setDefaultAddress(int addressId) =>
      '/api/v1/addresses/$addressId/set-default';

  static String editAddress(int addressId) => '/api/v1/addresses/$addressId';
}
