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

  /// The single-address resource, shared by the edit (PUT) and delete (DELETE)
  /// endpoints — both address the same `/addresses/{id}` path.
  static String _addressById(int addressId) => '/api/v1/addresses/$addressId';

  static String editAddress(int addressId) => _addressById(addressId);

  static String deleteAddress(int addressId) => _addressById(addressId);
}
