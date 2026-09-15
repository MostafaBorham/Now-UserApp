import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/personal_information/presentation/widgets/profile_avatar.dart';






class ProfileInfo extends StatelessWidget {
  const ProfileInfo({
    super.key,
    this.name = 'Guest 123',
    this.avatarUrl,
  });

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileAvatar(size: 120, imageUrl: avatarUrl),
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
