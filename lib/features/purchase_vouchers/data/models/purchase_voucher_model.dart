






class PurchaseVoucherModel {
  final int id;
  final String code;
  final String name;
  final String type;
  final String discountType;
  final double discountValue;
  final String? startsAt;
  final String? expiresAt;
  final List<PurchaseVoucherStore> stores;

  const PurchaseVoucherModel({
    this.id = 0,
    this.code = '',
    this.name = '',
    this.type = 'platform',
    this.discountType = 'percentage',
    this.discountValue = 0,
    this.startsAt,
    this.expiresAt,
    this.stores = const <PurchaseVoucherStore>[],
  });

  bool get isPlatform => type == 'platform';
  bool get isPercentage => discountType == 'percentage';

  factory PurchaseVoucherModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PurchaseVoucherModel();

    return PurchaseVoucherModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'platform',
      discountType: json['discount_type']?.toString() ?? 'percentage',
      discountValue:
          double.tryParse(json['discount_value']?.toString() ?? '') ?? 0.0,
      startsAt: json['starts_at']?.toString(),
      expiresAt: json['expires_at']?.toString(),
      stores:
          (json['stores'] as List<dynamic>?)
              ?.map(
                (dynamic e) =>
                    PurchaseVoucherStore.fromJson(e as Map<String, dynamic>?),
              )
              .toList() ??
          const <PurchaseVoucherStore>[],
    );
  }
}


class PurchaseVoucherStore {
  final int id;


  final Map<String, dynamic>? name;

  const PurchaseVoucherStore({this.id = 0, this.name});

  factory PurchaseVoucherStore.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PurchaseVoucherStore();
    return PurchaseVoucherStore(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as Map<String, dynamic>?,
    );
  }
}
