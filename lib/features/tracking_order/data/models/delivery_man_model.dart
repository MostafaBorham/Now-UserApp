/// The delivery courier assigned to an order, carried on the order payload as
/// the nested `driver` object.
///
/// Deliberately a lightweight display slice — only the fields the tracking UI
/// needs (id, localized [name], [profileImg] and [phone]).
class DeliveryManModel {
  final int? id;

  /// Courier name as a plain display string.
  final String? name;

  final String? profileImg;
  final String? phone;

  const DeliveryManModel({this.id, this.name, this.profileImg, this.phone});

  factory DeliveryManModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DeliveryManModel();
    }

    return DeliveryManModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name']?.toString(),
      profileImg: json['profile_img']?.toString(),
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_img': profileImg,
      'phone': phone,
    };
  }
}
