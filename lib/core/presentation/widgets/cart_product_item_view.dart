import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';

class CartProductItemView extends StatefulWidget {
  const CartProductItemView({
    super.key,
    this.productName = 'Almarai Milk 2 Liters',
    this.storeName = 'Panda Store',
    this.imageUrl =
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTruTN7TKhs6EbZtBGtXkJjLwrXau6sw1eyrA&s',
    this.oldPrice = '10',
    this.newPrice = '10',
    this.initialQuantity = 1,
    this.onDelete,
    this.onQuantityChanged,
  });

  final String productName;
  final String storeName;
  final String imageUrl;
  final String oldPrice;
  final String newPrice;
  final int initialQuantity;
  final VoidCallback? onDelete;
  final ValueChanged<int>? onQuantityChanged;

  @override
  State<CartProductItemView> createState() => _CartProductItemViewState();
}

class _CartProductItemViewState extends State<CartProductItemView> {
  late int _quantity = widget.initialQuantity;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 12,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: SizedBox(
            width: 76,
            height: 76,
            child: AppCachedNetworkImage(
              width: 76,
              height: 76,
              fit: BoxFit.cover,
              imageUrl: widget.imageUrl,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.productName,
                          maxLines: 1,
                          style: AppTextStyles.style16Medium.copyWith(
                            color: colors.tertiaryContainer,
                          ),
                        ),
                        Text(
                          widget.storeName,
                          maxLines: 1,
                          style: AppTextStyles.style14Regular.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: widget.onDelete,
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colors.error.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Assets.media.images.svg.deleteIcon
                          .svg(
                          colorFilter: ColorFilter.mode(colors.onError, BlendMode.srcIn)
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.ltr,
                    spacing: 4,
                    children: [
                      OldPriceWidget(
                        color: colors.onSurface,
                        price: widget.oldPrice,
                        size: 10,
                      ),
                      NewPriceWidget(
                        color: colors.onSecondary,
                        price: widget.newPrice,
                        size: 14,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() => _quantity++);
                          widget.onQuantityChanged?.call(_quantity);
                        },
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
                            size: 16,
                            color: colors.onSecondary,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 28,
                        child: Text(
                          _quantity.toString(),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.style14Medium.copyWith(
                            color: colors.tertiaryContainer,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: _quantity > 1
                            ? () {
                          setState(() => _quantity--);
                          widget.onQuantityChanged?.call(_quantity);
                        }
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
                            size: 16,
                            color: colors.onSurface,
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
    );
  }
}
