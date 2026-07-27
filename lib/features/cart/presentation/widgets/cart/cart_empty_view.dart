import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';

class CartEmptyView extends StatelessWidget {
  const CartEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context,con) {
          return Column(
            spacing: 10,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AspectRatio(
                  aspectRatio: 2,
                  child: Assets.media.images.svg.emptyCartImg.svg()),
              Text(
                'Your cart is empty!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: con.maxWidth*0.06,color: colors.onSecondary),
              ),
              Text(
                'You haven\'t added any products yet. Start shopping and discover the best deals.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: con.maxWidth*0.04),
              ),
              AspectRatio(
                  aspectRatio: 8,
                  child: PrimaryAppButton(title: 'Browse products',))
            ],
          );
        }
      ),
    );
  }
}
