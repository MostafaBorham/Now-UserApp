import 'package:equatable/equatable.dart';


enum RateableType {
  vendor('vendor'),
  deliveryMan('delivery_man');

  const RateableType(this.value);


  final String value;
}






class RateRequestModel extends Equatable {

  final String sourceType;


  final int sourceId;


  final RateableType rateableType;


  final int rateableId;


  final int score;


  final String comment;

  const RateRequestModel({
    this.sourceType = _defaultSourceType,
    required this.sourceId,
    required this.rateableType,
    required this.rateableId,
    required this.score,
    this.comment = '',
  });


  static const String _defaultSourceType = 'order';


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
