import 'dart:async';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';




class HomeOffersSectionView extends StatelessWidget {
  const HomeOffersSectionView({super.key, this.title, required this.offers});



  final Map<String, dynamic>? title;
  final List<HomeOfferModel> offers;

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) return const SizedBox.shrink();

    final AppColorScheme colors = context.colors;
    final String localizedTitle = context.getLocalizedApiText(title);
    final String heading = localizedTitle.isNotEmpty
        ? localizedTitle
        : LangKeys.specialOffersKey.tr();



    return LayoutBuilder(
      builder: (context, con) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(start: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(
                heading,
                style: TextStyle(
                  fontSize: con.maxWidth * 0.05,
                  color: colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: con.maxWidth * 0.4,
                child: _AutoScrollOffersList(offers: offers),
              ),
            ],
          ),
        );
      },
    );
  }
}




void _onOfferTap(BuildContext context, HomeOfferModel offer) {
  switch (offer.kind) {
    case 'store':
      if (offer.storeId != null) {
        context.pushNamed(AppRoutes.storeDetailsScreen, extra: offer.storeId);
      }
      break;
    case 'product':
      final String? slug = offer.productSlug;
      if (slug != null && slug.isNotEmpty) {
        context.pushNamed(AppRoutes.productDetailsScreen, extra: slug);
      }
      break;
    case 'category':


      final String? categorySlug = offer.categorySlug;
      if (categorySlug != null && categorySlug.isNotEmpty) {
        context.pushNamed(
          AppRoutes.categoryDetailsScreen,
          extra: CategoryModel(slug: categorySlug),
        );
      }
      break;
  }
}

class _AutoScrollOffersList extends StatefulWidget {
  const _AutoScrollOffersList({required this.offers});

  final List<HomeOfferModel> offers;

  @override
  State<_AutoScrollOffersList> createState() => _AutoScrollOffersListState();
}

class _AutoScrollOffersListState extends State<_AutoScrollOffersList> {
  static const Duration _dwell = Duration(seconds: 3);
  static const Duration _step = Duration(milliseconds: 900);
  static const double _separator = 12;
  static const double _aspectRatio = 0.7;

  final ScrollController _controller = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _timer = Timer.periodic(_dwell, (_) => _stepForward());
    });
  }

  void _stepForward() {
    if (!_controller.hasClients) return;
    final ScrollPosition position = _controller.position;
    final double max = position.maxScrollExtent;
    if (max <= 0) return;




    final double listHeight = context.size?.height ?? 0;
    if (listHeight <= 0) return;
    final double itemExtent = listHeight * _aspectRatio + _separator;

    final double target = position.pixels >= max - 1.0
        ? 0.0
        : (position.pixels + itemExtent).clamp(0.0, max);

    _controller.animateTo(target, duration: _step, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _controller,
      padding: const EdgeInsetsDirectional.only(end: 10),
      scrollDirection: Axis.horizontal,





      reverse: true,
      itemBuilder: (context, index) {
        final HomeOfferModel offer = widget.offers[index];
        return RepaintBoundary(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _onOfferTap(context, offer),
            child: AspectRatio(
              aspectRatio: _aspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AppCachedNetworkImage(
                  imageUrl: offer.imageUrl ?? '',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemCount: widget.offers.length,
    );
  }
}
