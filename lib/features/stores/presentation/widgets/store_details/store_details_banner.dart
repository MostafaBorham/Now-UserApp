import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';

class StoreDetailsBanner extends StatelessWidget {
  const StoreDetailsBanner({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadiusGeometry.circular(16),
      ),
      child: AppCachedNetworkImage(
        imageUrl:
        'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcTJaJMzZSckLOl3zfGEfivgtfRbdIq1b14vbXIx433yCcfpUdCJ',
        width: double.infinity,
      ),
    );
  }
}