import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';

class MostPopularItem extends StatelessWidget {
  const MostPopularItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          width: 100,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: AppBorderRadius.brCircular10
          ),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              CachedNetworkImage(imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Tomato_je.jpg/1280px-Tomato_je.jpg',fit: BoxFit.cover,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                      radius: 20,
                      backgroundColor: colors.onPrimary,
                      child: Icon(Icons.favorite_border)),
                  Column(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),topRight: Radius.circular(20)),
                          color: colors.errorContainer
                        ),
                        child: AutoSizeText('50%'),
                      ),
                      Container(
                        width: 35,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(20),bottomLeft: Radius.circular(20)),
                          color: colors.primary
                        ),
                        child: AutoSizeText('50%'),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
        Container()
      ],
    );
  }
}