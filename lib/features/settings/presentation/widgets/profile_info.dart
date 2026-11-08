import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/personal_information/presentation/widgets/profile_avatar.dart';

/// Avatar + name, centered under the header.
///
/// The avatar shows the user's real picture when [avatarUrl] is provided
/// (rendered by [ProfileAvatar], which attaches the bearer token), otherwise
/// the placeholder.
class ProfileInfo extends StatelessWidget {
  const ProfileInfo({super.key, required this.name, this.avatarUrl});

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileAvatar(size: 120, imageUrl: avatarUrl, fullScreenOnTap: true),
        const SizedBox(height: 14),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
