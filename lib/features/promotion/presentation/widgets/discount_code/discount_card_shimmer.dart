import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/clippers/ticket_clipper.dart';

class DiscountCardShimmer extends StatelessWidget {
  const DiscountCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: AspectRatio(
        aspectRatio: 2.2,
        child: ClipPath(
          clipper: TicketClipper(textDirection: Directionality.of(context)),
          child: Container(
            color: context.colors.neutral500,
          ),
        ),
      ),
    );
  }
}
