import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class HomeViewAllWidget extends StatelessWidget {
  const HomeViewAllWidget({
    super.key,
    required this.size, required this.startBackgroundColor, this.endBackgroundColor, this.textColor,
  });

  final double size;
  final Color startBackgroundColor;
  final Color? endBackgroundColor;
  final Color? textColor;
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Stack(
      alignment: AlignmentDirectional.centerStart,
      children: [
        Positioned.fill(
          child: FractionallySizedBox(
            widthFactor: 0.8,
            heightFactor: 0.6,
            alignment: AlignmentDirectional.bottomEnd,
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadiusGeometry.circular(100),
                gradient: LinearGradient(
                  colors: [endBackgroundColor?? colors.white,startBackgroundColor],
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                ),
              ),
            ),
          ),
        ),
        Text(
          'View All',
          style: TextStyle(
            fontSize: size,
            color: textColor?? colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}