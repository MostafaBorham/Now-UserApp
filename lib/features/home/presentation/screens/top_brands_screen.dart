import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/top_brands/top_brands_view.dart';

class TopBrandsScreen extends StatelessWidget {
  const TopBrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppWavedView(
        body: TopBrandsView(),
        appBarTitle: context.tr(LangKeys.topBrandsKey),
      ),
    );
  }
}
