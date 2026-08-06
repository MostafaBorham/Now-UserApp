import 'package:equatable/equatable.dart';
import 'package:nowdelivery_user_app/features/settings/data/models/faq_model.dart';
import 'package:nowdelivery_user_app/features/settings/data/models/privacy_model.dart';

/// The `data` payload of `GET /api/v1/application-information`.
///
/// Combines the two sub-models of the endpoint: [content] (the legal/info text
/// blocks — see [PrivacyModel]) and [faqs] (the list of [FaqModel] entries).
class AppInfoModel extends Equatable {
  final String? scope;
  final PrivacyModel? content;
  final List<FaqModel> faqs;

  const AppInfoModel({
    this.scope,
    this.content,
    this.faqs = const <FaqModel>[],
  });

  factory AppInfoModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AppInfoModel();
    }

    final List<dynamic> rawFaqs = json['faqs'] as List<dynamic>? ?? <dynamic>[];

    return AppInfoModel(
      scope: json['scope']?.toString(),
      content: PrivacyModel.fromJson(json['content'] as Map<String, dynamic>?),
      faqs: rawFaqs
          .map((dynamic e) => FaqModel.fromJson(e as Map<String, dynamic>?))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scope': scope,
      'content': content?.toJson(),
      'faqs': faqs.map((FaqModel e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [scope, content, faqs];
}
