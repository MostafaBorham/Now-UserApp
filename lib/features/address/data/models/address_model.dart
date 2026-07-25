import 'package:equatable/equatable.dart';

/// A single address entry from `GET /api/v1/addresses`.
class AddressModel extends Equatable {
  final int? id;
  final int? userId;
  final String? label;
  final String? phone;
  final String? country;
  final String? city;
  final String? area;
  final String? street;
  final String? buildingNumber;
  final String? floor;
  final String? apartment;
  final String? latitude;
  final String? longitude;
  final String? notes;
  final bool? isDefault;
  final String? fullAddress;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  const AddressModel({
    this.id,
    this.userId,
    this.label,
    this.phone,
    this.country,
    this.city,
    this.area,
    this.street,
    this.buildingNumber,
    this.floor,
    this.apartment,
    this.latitude,
    this.longitude,
    this.notes,
    this.isDefault,
    this.fullAddress,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AddressModel();
    }

    return AddressModel(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['user_id'] as num?)?.toInt(),
      label: json['label']?.toString(),
      phone: json['phone']?.toString(),
      country: json['country']?.toString(),
      city: json['city']?.toString(),
      area: json['area']?.toString(),
      street: json['street']?.toString(),
      buildingNumber: json['building_number']?.toString(),
      floor: json['floor']?.toString(),
      apartment: json['apartment']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      notes: json['notes']?.toString(),
      isDefault: json['is_default'] as bool?,
      fullAddress: json['full_address']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      deletedAt: json['deleted_at']?.toString(),
    );
  }

  AddressModel copyWith({
    int? id,
    int? userId,
    String? label,
    String? phone,
    String? country,
    String? city,
    String? area,
    String? street,
    String? buildingNumber,
    String? floor,
    String? apartment,
    String? latitude,
    String? longitude,
    String? notes,
    bool? isDefault,
    String? fullAddress,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      city: city ?? this.city,
      area: area ?? this.area,
      street: street ?? this.street,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      floor: floor ?? this.floor,
      apartment: apartment ?? this.apartment,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notes: notes ?? this.notes,
      isDefault: isDefault ?? this.isDefault,
      fullAddress: fullAddress ?? this.fullAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'label': label,
      'phone': phone,
      'country': country,
      'city': city,
      'area': area,
      'street': street,
      'building_number': buildingNumber,
      'floor': floor,
      'apartment': apartment,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'is_default': isDefault,
      'full_address': fullAddress,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        label,
        phone,
        country,
        city,
        area,
        street,
        buildingNumber,
        floor,
        apartment,
        latitude,
        longitude,
        notes,
        isDefault,
        fullAddress,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}
