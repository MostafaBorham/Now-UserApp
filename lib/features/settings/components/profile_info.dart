import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

import '../app_colors.dart';

/// Avatar + name + "member since" date pill, centered under the header.
///
/// The avatar is rendered from the provided `person.svg` placeholder inside
/// a clipped circle.
class ProfileInfo extends StatelessWidget {
  const ProfileInfo({
    super.key,
    this.name = 'Guest 123',
    this.memberSince = 'October 2, 2025',
  });

  final String name;
  final String memberSince;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
          Assets.media.images.svg.personPng.image(),
        const SizedBox(height: 14),
        Text(
          name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.datePillBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            memberSince,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.datePillText,
            ),
          ),
        ),
      ],
    );
  }
}
