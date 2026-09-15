
abstract class AddressEndpoints {
  static const int _perPage = 15;

  static const String addresses = '/api/v1/addresses';
  static const String defaultAddress = '/api/v1/addresses/default';



  static Map<String, dynamic> myAddressesQuery(int page) => <String, dynamic>{
    'per_page': _perPage,
    'page': page,
  };

  static String setDefaultAddress(int addressId) =>
      '/api/v1/addresses/$addressId/set-default';



  static String _addressById(int addressId) => '/api/v1/addresses/$addressId';

  static String editAddress(int addressId) => _addressById(addressId);

  static String deleteAddress(int addressId) => _addressById(addressId);
}
