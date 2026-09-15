
abstract class SupportEndpoints {
  static const String supportTickets = '/api/v1/me/support-tickets';
  static const String ratings = '/api/v1/ratings';


  static const String aboutInformation =
      '/api/v1/application-information/about';

  static Map<String, dynamic> aboutInformationQuery() => {
    'scope': 'user',
  };
}
