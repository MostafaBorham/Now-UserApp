import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/common/presentation/widgets/images/app_cached_network_image.dart';

class TopBrandsItem extends StatelessWidget {
  const TopBrandsItem({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context,con) {
        return Column(
          spacing: 10,
          children: [
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                decoration: BoxDecoration(
                  color: colors.inversePrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppCachedNetworkImage(imageUrl: 'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',fit: BoxFit.contain,width: con.maxWidth*0.3,),
              ),
            ),
            Text('Panda',style: TextStyle(
              color: colors.onSecondary,
              fontSize: con.maxWidth*0.08,
              fontWeight: FontWeight.w500
            ),)
          ],
        );
      }
    );
  }
}