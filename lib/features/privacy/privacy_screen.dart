import 'package:flutter/material.dart';
import 'package:user_app/settings/app_colors.dart';
import 'package:user_app/settings/components/profile_header.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CommonHeader(
            title: 'Privacy Policy',
            onBack: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}
