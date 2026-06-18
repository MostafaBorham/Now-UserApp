import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/home/circular_brand_logo.dart';

import 'buttons/primary_app_prefix_icon_button.dart';
import 'reverse_widget.dart';

class AppWavedScaffold extends StatelessWidget {
  const AppWavedScaffold({super.key, required this.appBar, required this.body});
  final Widget appBar;
  final Widget body;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final LinearGradient screenGradient = LinearGradient(
      begin: AlignmentDirectional.centerStart,
      end: AlignmentDirectional.centerEnd,
      colors: [Color(0xffFFFDE6), Color(0xffDBF1DB).withValues(alpha: 0.6)],
    );
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 70),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.onSecondaryFixed,
              colors.onPrimary,
              colors.onPrimary,
            ],
          ),
        ),
        child: Column(
          spacing: 20,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: appBar,
            ),
            Expanded(
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Assets.media.images.svg.whiteWaveBackground.svg(
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 50.0,
                    ),
                    child: body,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
