import 'package:equatable/equatable.dart';
import 'package:nowdelivery_user_app/core/extensions/json_parsing.dart';

class BannerModel extends Equatable {
  final int? id;
  final String? type;
  final String? linkType;
  final String? defaultUrl;
  final String? image;

  const BannerModel({
    this.id,
    this.type,
    this.linkType,
    this.defaultUrl,
    this.image,
  });

  factory BannerModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const BannerModel();
    }

    return BannerModel(
      id: (json['id'] as num?)?.toInt(),
      type: json['type']?.toString(),
      linkType: json['link_type']?.toString(),
      defaultUrl: json['default_url']?.toString(),
      image: json.downloadUrl('image'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'link_type': linkType,
      'default_url': defaultUrl,
      'image': image == null
          ? null
          : {
        'download_url': image,
      },
    };
  }

  @override
  List<Object?> get props => [
    id,
    type,
    linkType,
    defaultUrl,
    image,
  ];
}
