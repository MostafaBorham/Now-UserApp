import 'package:equatable/equatable.dart';



class RateResponseModel extends Equatable {
  final int? id;
  final RatingSource? source;
  final RatingRater? rater;
  final RatingRateable? rateable;
  final int? score;
  final String? stars;
  final String? comment;
  final String? category;
  final String? status;
  final String? ratedAt;
  final String? createdAt;
  final bool? isOwner;
  final bool? canEdit;
  final bool? canDelete;

  const RateResponseModel({
    this.id,
    this.source,
    this.rater,
    this.rateable,
    this.score,
    this.stars,
    this.comment,
    this.category,
    this.status,
    this.ratedAt,
    this.createdAt,
    this.isOwner,
    this.canEdit,
    this.canDelete,
  });

  factory RateResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const RateResponseModel();
    }

    return RateResponseModel(
      id: (json['id'] as num?)?.toInt(),
      source: json['source'] is Map<String, dynamic>
          ? RatingSource.fromJson(json['source'] as Map<String, dynamic>)
          : null,
      rater: json['rater'] is Map<String, dynamic>
          ? RatingRater.fromJson(json['rater'] as Map<String, dynamic>)
          : null,
      rateable: json['rateable'] is Map<String, dynamic>
          ? RatingRateable.fromJson(json['rateable'] as Map<String, dynamic>)
          : null,
      score: (json['score'] as num?)?.toInt(),
      stars: json['stars']?.toString(),
      comment: json['comment']?.toString(),
      category: json['category']?.toString(),
      status: json['status']?.toString(),
      ratedAt: json['rated_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      isOwner: json['is_owner'] as bool?,
      canEdit: json['can_edit'] as bool?,
      canDelete: json['can_delete'] as bool?,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        source,
        rater,
        rateable,
        score,
        stars,
        comment,
        category,
        status,
        ratedAt,
        createdAt,
        isOwner,
        canEdit,
        canDelete,
      ];
}


class RatingSource extends Equatable {
  final String? type;
  final int? id;

  const RatingSource({this.type, this.id});

  factory RatingSource.fromJson(Map<String, dynamic> json) {
    return RatingSource(
      type: json['type']?.toString(),
      id: (json['id'] as num?)?.toInt(),
    );
  }

  @override
  List<Object?> get props => <Object?>[type, id];
}


class RatingRater extends Equatable {
  final String? type;
  final int? id;
  final bool? isMe;

  const RatingRater({this.type, this.id, this.isMe});

  factory RatingRater.fromJson(Map<String, dynamic> json) {
    return RatingRater(
      type: json['type']?.toString(),
      id: (json['id'] as num?)?.toInt(),
      isMe: json['is_me'] as bool?,
    );
  }

  @override
  List<Object?> get props => <Object?>[type, id, isMe];
}


class RatingRateable extends Equatable {
  final String? type;
  final int? id;

  const RatingRateable({this.type, this.id});

  factory RatingRateable.fromJson(Map<String, dynamic> json) {
    return RatingRateable(
      type: json['type']?.toString(),
      id: (json['id'] as num?)?.toInt(),
    );
  }

  @override
  List<Object?> get props => <Object?>[type, id];
}
