/// Aggregated rating of a store or a product as sent by the API under the
/// `rating` key, e.g.
/// ```json
/// "rating": { "average": 2.5, "total": 16, "distribution": { "5": 0, "4": 4, ... } }
/// ```
class RatingModel {
  /// Mean star rating (e.g. `2.5`).
  final double? average;

  /// Total number of ratings the [average] is computed from.
  final int? total;

  /// How the ratings break down per star, keyed by the star value (`1`–`5`)
  /// mapped to how many ratings gave that many stars.
  final Map<int, int>? distribution;

  const RatingModel({this.average, this.total, this.distribution});

  factory RatingModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const RatingModel();

    return RatingModel(
      average: (json['average'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toInt(),
      distribution: (json['distribution'] as Map<String, dynamic>?)?.map(
        (star, count) =>
            MapEntry(int.tryParse(star) ?? 0, (count as num?)?.toInt() ?? 0),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average': average,
      'total': total,
      'distribution': distribution?.map(
        (star, count) => MapEntry(star.toString(), count),
      ),
    };
  }

  RatingModel copyWith({
    double? average,
    int? total,
    Map<int, int>? distribution,
  }) {
    return RatingModel(
      average: average ?? this.average,
      total: total ?? this.total,
      distribution: distribution ?? this.distribution,
    );
  }
}
