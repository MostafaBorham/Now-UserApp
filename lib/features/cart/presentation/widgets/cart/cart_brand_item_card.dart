/*
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';

class CartBrandItemCard extends StatelessWidget {
  const CartBrandItemCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return ExpansionTile(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          CircularBrandLogo(
            radius: 20,
            logoUrl:
                'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
          ),
          Expanded(
            child: Text('Banda Store',style: AppTextStyles.style16Medium.copyWith(
              color: colors.onSecondary
            ),),
          )
        ],
      ),
      backgroundColor: colors.onSurface.withValues(alpha: 0.2),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_postfix_icon_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_prefix_icon_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';

class CartBrandItemCard extends StatefulWidget {
  const CartBrandItemCard({super.key});

  @override
  State<CartBrandItemCard> createState() => _CartBrandItemCardState();
}

class _CartBrandItemCardState extends State<CartBrandItemCard> {
  bool _isExpanded = false;
  final List<bool> _checked = [true, false];
  final List<int> _quantities = [1, 1];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.onPrimaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            // Store header (tap to expand / collapse)
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12,
                    children: [
                      CircularBrandLogo(
                        radius: 24,
                        elevation: 1,
                        backgroundColor: colors.onTertiaryContainer,
                        logoUrl:
                            'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                      ),
                      Text(
                        'Banda Store',
                        style: AppTextStyles.style16Medium.copyWith(
                          color: colors.onSecondary,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 24,
                    color: colors.onSurface.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),

            // Collapsed preview: product thumbnails
            if (!_isExpanded)
              Row(
                spacing: 8,
                children: [
                  for (int i = 0; i < 2; i++)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: AppCachedNetworkImage(
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          imageUrl:
                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTruTN7TKhs6EbZtBGtXkJjLwrXau6sw1eyrA&s',
                        ),
                      ),
                    ),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colors.onPrimary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '+',
                        style: AppTextStyles.style28Medium.copyWith(
                          color: colors.onSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            // Expanded content: product list, add more, invoice summary
            if (_isExpanded) ...[
              Column(
                spacing: 16,
                children: [
                  for (int i = 0; i < 2; i++)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 12,
                      children: [
                        /*InkWell(
                          onTap: () =>
                              setState(() => _checked[i] = !_checked[i]),
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _checked[i]
                                  ? colors.primary
                                  : colors.onPrimary,
                              borderRadius: BorderRadius.circular(6),
                              border: _checked[i]
                                  ? null
                                  : Border.all(
                                      color: colors.surfaceContainerLow,
                                    ),
                            ),
                            child: _checked[i]
                                ? Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: colors.onPrimary,
                                  )
                                : null,
                          ),
                        ),*/
                        ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: SizedBox(
                            width: 76,
                            height: 76,
                            child: AppCachedNetworkImage(
                              width: 76,
                              height: 76,
                              fit: BoxFit.cover,
                              imageUrl:
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTruTN7TKhs6EbZtBGtXkJjLwrXau6sw1eyrA&s',
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 16,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Almarai Milk 2 Liters',
                                          maxLines: 1,
                                          style: AppTextStyles.style16Medium
                                              .copyWith(
                                                color: colors.tertiaryContainer,
                                              ),
                                        ),
                                        Text(
                                          'Panda Store',
                                          maxLines: 1,
                                          style: AppTextStyles.style14Regular
                                              .copyWith(
                                                color: colors.onSurface,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {},
                                    customBorder: const CircleBorder(),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: colors.surfaceBright,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Assets.media.images.svg.deleteIcon
                                          .svg(),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    textDirection: TextDirection.ltr,
                                    spacing: 4,
                                    children: [
                                      OldPriceWidget(
                                        color: colors.onSurface,
                                        price: '10',
                                        size: 10,
                                      ),
                                      NewPriceWidget(
                                        color: colors.onSecondary,
                                        price: '10',
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 4,
                                    children: [
                                      InkWell(
                                        onTap: () =>
                                            setState(() => _quantities[i]++),
                                        customBorder: const CircleBorder(),
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: colors.onPrimary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.add_rounded,
                                            size: 20,
                                            color: colors.onSecondary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 28,
                                        child: Text(
                                          _quantities[i].toString(),
                                          textAlign: TextAlign.center,
                                          style: AppTextStyles.style14Medium
                                              .copyWith(
                                                color: colors.tertiaryContainer,
                                              ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: _quantities[i] > 1
                                            ? () => setState(
                                                () => _quantities[i]--,
                                              )
                                            : null,
                                        customBorder: const CircleBorder(),
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: colors.onPrimary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.remove_rounded,
                                            size: 20,
                                            color: colors.onSurface.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colors.onPrimary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 10,
                          children: [
                            Assets.media.images.svg.circleAddMoreBrokenIcon
                                .svg(),
                            Text(
                              'Add More Items',
                              style: AppTextStyles.style14Medium.copyWith(
                                color: colors.onTertiaryFixed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Store invoice summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceDim,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Text(
                      'Store Invoice Summary',
                      style: AppTextStyles.style16Medium.copyWith(
                        color: colors.tertiaryContainer,
                      ),
                    ),
                    for (final String label in const [
                      'Subtotal',
                      'Vat (5%)',
                      'Delivery Fee',
                    ])
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              label,
                              style: AppTextStyles.style14Regular.copyWith(
                                color: colors.onSecondary,
                              ),
                            ),
                          ),
                          NewPriceWidget(
                            color: colors.onSecondary,
                            price: '10',
                            size: 13,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],

            // Total + checkout pill (shared between both states)
            Container(
              padding: const EdgeInsetsDirectional.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                  colors: [
                    colors.onTertiaryFixedVariant,
                    colors.onSurfaceVariant,
                  ],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 12,
                      children: [
                        Text(
                          'Total',
                          style: AppTextStyles.style16SemiBold.copyWith(
                            color: colors.tertiaryContainer,
                          ),
                        ),
                        NewPriceWidget(
                          color: colors.onSecondary,
                          price: '10',
                          size: 17,
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(999),
                      clipBehavior: Clip.antiAlias,
                      child: PrimaryAppPostfixIconButton(
                        title: 'Checkout',
                        postfixIcon: Assets
                            .media
                            .images
                            .svg
                            .rightArrowBrokenIcon
                            .svg(),
                        buttonPadding: 8,
                      ),
                    ),
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
