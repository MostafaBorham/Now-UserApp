/// API endpoints owned by the support feature.
abstract class SupportEndpoints {
  static const String supportTickets = '/api/v1/me/support-tickets';

  /// About-section application information (its FAQs) for a given scope.
  static const String aboutInformation =
      '/api/v1/application-information/about';

  static Map<String, dynamic> aboutInformationQuery() => {
    'scope': 'user',
  };
}
