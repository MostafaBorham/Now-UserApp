import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/current_price_with_currency.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/primary_app_button.dart';

class OrderListItem extends ConsumerWidget {
  const OrderListItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colors.onPrimaryContainer,
        borderRadius: AppBorderRadius.brCircular16.r,
        boxShadow: [
          BoxShadow(
            color: colors.onSurface.withValues(alpha: 0.08),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 5,
                children: [
                  Assets.media.images.svg.realSaudiCurrency.svg(
                    width: 14.sp,
                    height: 14.sp,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      colors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  AutoSizeText(
                    '20.00',
                    style: AppTextStyles.style16SemiBold.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AutoSizeText(
                      '#ORD-458921',
                      style: AppTextStyles.style18SemiBold.copyWith(
                        color: colors.onSecondary,
                      ),
                    ),
                    4.hSpace,
                    AutoSizeText(
                      'تم التسليم في 12 مارس 2026',
                      style: AppTextStyles.style14Regular.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    10.hSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.onSecondaryFixed.withValues(
                              alpha: 0.4,
                            ),
                            borderRadius: AppBorderRadius.brCircular20.r,
                          ),
                          child: AutoSizeText(
                            'قيد الانتظار',
                            style: AppTextStyles.style12Medium.copyWith(
                              color: colors.onErrorContainer,
                            ),
                          ),
                        ),
                        8.wSpace,
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.onSurface.withValues(alpha: 0.1),
                            borderRadius: AppBorderRadius.brCircular20.r,
                          ),
                          child: AutoSizeText(
                            '5 عناصر',
                            style: AppTextStyles.style16Medium.copyWith(
                              color: colors.onSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              12.wSpace,
              ClipRRect(
                borderRadius: AppBorderRadius.brCircular12.r,
                child: CachedNetworkImage(
                  imageUrl:
                      'https://www.shutterstock.com/image-photo/various-kinds-fresh-colorful-fruits-260nw-2698161807.jpg',
                  width: 88.w,
                  height: 88.w,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          14.hSpace,
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colors.onSurface.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: AutoSizeText(
                      'تتبع الطلب',
                      textAlign: TextAlign.center,
                      minFontSize: 10,
                      style: AppTextStyles.style14Medium.copyWith(
                        color: colors.onSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              12.wSpace,
              Expanded(
                child: PrimaryAppButton(isFilled: true, title: 'عرض التفاصيل'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
