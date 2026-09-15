class RatingModel {
  final double? average;

  final int? total;

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
