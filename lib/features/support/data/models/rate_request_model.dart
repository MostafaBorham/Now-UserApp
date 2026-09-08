import 'package:equatable/equatable.dart';

/// What is being rated, mapped to the `rateable_type` value the API expects.
enum RateableType {
  vendor('vendor'),
  deliveryMan('delivery_man');

  const RateableType(this.value);

  /// The exact string sent in the request body.
  final String value;
}

/// The body of `POST /api/v1/ratings`, shared by both the store rating and the
/// delivery-man rating (they differ only in [rateableType] and [rateableId]).
///
/// Build it with [RateRequestModel.store] / [RateRequestModel.deliveryMan] so
/// the caller only supplies the ids, score and comment.
class RateRequestModel extends Equatable {
  /// What the rating is attached to. Fixed to an order for now.
  final String sourceType;

  /// Id of the [sourceType] — the order id.
  final int sourceId;

  /// The kind of entity being rated (vendor / delivery man).
  final RateableType rateableType;

  /// Id of the rated entity — store id for a vendor, delivery-man id otherwise.
  final int rateableId;

  /// Star score, 1–5.
  final int score;

  /// Free-text review the user typed.
  final String comment;

  const RateRequestModel({
    this.sourceType = _defaultSourceType,
    required this.sourceId,
    required this.rateableType,
    required this.rateableId,
    required this.score,
    this.comment = '',
  });

  /// Source kind the backend expects until other sources exist.
  static const String _defaultSourceType = 'order';

  /// Rating for a store (vendor): [orderId] is the order, [storeId] the vendor.
  const RateRequestModel.store({
    required int orderId,
    required int storeId,
    required int score,
    String comment = '',
  }) : this(
          sourceId: orderId,
          rateableType: RateableType.vendor,
          rateableId: storeId,
          score: score,
          comment: comment,
        );

  /// Rating for a delivery man: [orderId] is the order, [deliveryManId] the man.
  const RateRequestModel.deliveryMan({
    required int orderId,
    required int deliveryManId,
    required int score,
    String comment = '',
  }) : this(
          sourceId: orderId,
          rateableType: RateableType.deliveryMan,
          rateableId: deliveryManId,
          score: score,
          comment: comment,
        );

  RateRequestModel copyWith({
    String? sourceType,
    int? sourceId,
    RateableType? rateableType,
    int? rateableId,
    int? score,
    String? comment,
  }) {
    return RateRequestModel(
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      rateableType: rateableType ?? this.rateableType,
      rateableId: rateableId ?? this.rateableId,
      score: score ?? this.score,
      comment: comment ?? this.comment,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'source_type': sourceType,
      'source_id': sourceId,
      'rateable_type': rateableType.value,
      'rateable_id': rateableId,
      'score': score,
      'comment': comment,
    };
  }

  @override
  List<Object?> get props => <Object?>[
        sourceType,
        sourceId,
        rateableType,
        rateableId,
        score,
        comment,
      ];
}
