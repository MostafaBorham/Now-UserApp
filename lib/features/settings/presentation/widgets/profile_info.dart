import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/loading_view_types.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// Avatar + name, centered under the header.
///
/// The avatar is rendered from the provided `person.svg` placeholder inside
/// a clipped circle.
class ProfileInfo extends StatelessWidget {
  const ProfileInfo({
    super.key,
    this.name = 'Guest 123',
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Assets.media.images.svg.personPng.image(),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(shape: BoxShape.circle),
          child: AppCachedNetworkImage(
            // width: 120,
            // height: 120,
            placeholderType: LoadingViewTypes.shimmer,
            fit: BoxFit.cover,
            width: 120,
            height: 120,
            imageUrl:
                "https://cdn-icons-png.flaticon.com/512/17552/17552522.png",
          ),
        ),
        const SizedBox(height: 14),
        Text(
          name,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: context.colors.tertiaryContainer,
          ),
        ),
      ],
    );
  }
}
