import 'package:equatable/equatable.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A single address entry from `GET /api/v1/addresses`.
class AddressModel extends Equatable {
  final int? id;
  final int? userId;

  /// Localized address label as an API translation map (`{'en': ..., 'ar': ...}`).
  /// Resolve it for display with `context.getLocalizedApiText(label)`.
  final Map<String, dynamic>? label;
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

  /// The `label` values the backend accepts, in the order the details screen's
  /// segmented selector shows them (home / work / other).
  ///
  /// Each entry mirrors the API translation shape (`{'en': ..., 'ar': ...}`) so
  /// the label round-trips as a localized value rather than a bare identifier.
  /// Editing the copy here changes stored data, not just what is displayed.
  static const List<Map<String, String>> labelOptions = <Map<String, String>>[
    <String, String>{'en': 'Home', 'ar': 'المنزل'},
    <String, String>{'en': 'Work', 'ar': 'العمل'},
    <String, String>{'en': 'Other', 'ar': 'أخرى'},
  ];

  factory AddressModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AddressModel();
    }

    return AddressModel(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['user_id'] as num?)?.toInt(),
      label: (json['label'] is String)
          ? {'ar': json['label'] as String, 'en': json['label'] as String}
          : json['label'],
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

  /// Builds a display/draft address from a reverse-geocoded [placemark] at
  /// [location]. Composes the area from the placemark's locality parts and
  /// carries the picked coordinates; the backend still owns `full_address`, so
  /// it is left unset here.
  factory AddressModel.fromPlacemark(Placemark placemark, LatLng location) {
    final String area = <String?>[
      placemark.subLocality,
      placemark.locality,
      placemark.administrativeArea,
    ].whereType<String>().where((String e) => e.isNotEmpty).join(' - ');

    return AddressModel(
      country: placemark.country,
      city: placemark.locality,
      area: area.isEmpty ? placemark.name : area,
      street: placemark.street,
      latitude: location.latitude.toString(),
      longitude: location.longitude.toString(),
    );
  }

  AddressModel copyWith({
    int? id,
    int? userId,
    Map<String, dynamic>? label,
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

  /// The request body for creating and updating an address — the same shape
  /// for both.
  ///
  /// Only client-owned fields are sent: `id`, `user_id`, `full_address` and the
  /// timestamps are assigned by the server. `label` goes out as its English
  /// value (the backend owns the translation), and the coordinates as numbers
  /// rather than the strings the read model keeps them in.
  Map<String, dynamic> toRequestJson() {
    return <String, dynamic>{
      'label': label?['en'],
      'phone': phone,
      'country': country,
      'city': city,
      'area': area,
      'street': street,
      'building_number': buildingNumber,
      'floor': floor,
      'apartment': apartment,
      'latitude': double.tryParse(latitude ?? ''),
      'longitude': double.tryParse(longitude ?? ''),
      'notes': notes,
      'is_default': isDefault ?? false,
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
