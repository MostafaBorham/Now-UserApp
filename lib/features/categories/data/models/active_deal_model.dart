import 'package:equatable/equatable.dart';

class ActiveDealModel extends Equatable {
  final int? id;
  final String? uuid;
  final String? name;
  final String? discountType;
  final double? discountValue;
  final String? scope;
  final int? priority;
  final String? status;
  final DateTime? startsAt;
  final DateTime? endsAt;

  const ActiveDealModel({
    this.id,
    this.uuid,
    this.name,
    this.discountType,
    this.discountValue,
    this.scope,
    this.priority,
    this.status,
    this.startsAt,
    this.endsAt,
  });

  factory ActiveDealModel.fromJson(Map<String, dynamic> json) {
    return ActiveDealModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String?,
      name: json['name'] as String?,
      discountType: json['discount_type'] as String?,
      discountValue: (json['discount_value'] as num?)?.toDouble(),
      scope: json['scope'] as String?,
      priority: json['priority'] as int?,
      status: json['status'] as String?,
      startsAt: json['starts_at'] != null
          ? DateTime.parse(json['starts_at'])
          : null,
      endsAt: json['ends_at'] != null
          ? DateTime.parse(json['ends_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'discount_type': discountType,
      'discount_value': discountValue,
      'scope': scope,
      'priority': priority,
      'status': status,
      'starts_at': startsAt?.toIso8601String(),
      'ends_at': endsAt?.toIso8601String(),
    };
  }

  ActiveDealModel copyWith({
    int? id,
    String? uuid,
    String? name,
    String? discountType,
    double? discountValue,
    String? scope,
    int? priority,
    String? status,
    DateTime? startsAt,
    DateTime? endsAt,
  }) {
    return ActiveDealModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      scope: scope ?? this.scope,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    uuid,
    name,
    discountType,
    discountValue,
    scope,
    priority,
    status,
    startsAt,
    endsAt,
  ];
}