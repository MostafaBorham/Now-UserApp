import 'package:equatable/equatable.dart';

/// A single FAQ entry from `GET /api/v1/application-information`.
///
/// [question] and [answer] are localized maps keyed by locale (`ar` / `en`);
/// [answer] values may contain HTML markup as returned by the server.
class FaqModel extends Equatable {
  final int? id;
  final Map<String, dynamic>? question;
  final Map<String, dynamic>? answer;

  const FaqModel({
    this.id,
    this.question,
    this.answer,
  });

  factory FaqModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const FaqModel();
    }

    return FaqModel(
      id: (json['id'] as num?)?.toInt(),
      question: json['question'] as Map<String, dynamic>?,
      answer: json['answer'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
    };
  }

  @override
  List<Object?> get props => [id, question, answer];
}
