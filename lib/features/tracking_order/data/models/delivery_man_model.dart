




class DeliveryManModel {
  final int? id;


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
