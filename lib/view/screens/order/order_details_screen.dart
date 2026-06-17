import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/theme/app_gradient_colors.dart';
import 'package:nowdelivery_user_app/view/widgets/home/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/view/widgets/order/order_list_item.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/primary_app_button.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final LinearGradient screenGradient = LinearGradient(
      begin: AlignmentDirectional.centerStart,
      end: AlignmentDirectional.centerEnd,
      colors: [Color(0xffFFFDE6), Color(0xffDBF1DB).withValues(alpha: 0.6)],
    );
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 70),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.onSecondaryFixed,
              colors.onPrimary,
              colors.onPrimary,
            ],
          ),
        ),
        child: Column(
          spacing: 20,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  15.wSpace,
                  AutoSizeText(
                    'Order Details',
                    style: AppTextStyles.style24SemiBold.copyWith(
                      color: colors.onSecondary,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: CircleAvatar(
                      backgroundColor: colors.onPrimary,
                      radius: 20.r,
                      child: Assets.media.images.svg.arrowBrokenIcon.svg(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Assets.media.images.svg.whiteWaveBackground.svg(
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 50.0,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        spacing: 15,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            spacing: 8,
                            children: [
                              Container(
                                width: 48.w,
                                height: 48.w,
                                decoration: BoxDecoration(
                                  gradient: screenGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Assets.media.images.svg.orderIcon.svg(
                                    width: 24.w,
                                    height: 24.w,
                                    colorFilter: ColorFilter.mode(
                                      colors.onSecondary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Order Number',
                                      style: AppTextStyles.style12Medium
                                          .copyWith(color: colors.onSurface),
                                    ),
                                    4.hSpace,
                                    Text(
                                      'Order #458741',
                                      style: AppTextStyles.style18SemiBold
                                          .copyWith(color: colors.onSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.1),
                                  borderRadius: AppBorderRadius.brCircular20.r,
                                ),
                                child: Text(
                                  'Delivered',
                                  style: AppTextStyles.style12Medium.copyWith(
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              /*    color: colors.secondary.withValues(
                                alpha: 0.1,
                              ),*/
                              gradient: screenGradient,
                              borderRadius: AppBorderRadius.brCircular12.r,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'General Information',
                                  style: AppTextStyles.style16SemiBold.copyWith(
                                    color: colors.onSecondary,
                                  ),
                                ),
                                12.hSpace,
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: colors.onPrimary,
                                    borderRadius: AppBorderRadius.brCircular8.r,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Order Number',
                                              style: AppTextStyles
                                                  .style14Regular
                                                  .copyWith(
                                                    color: colors.onSurface,
                                                  ),
                                            ),
                                          ),
                                          Text(
                                            '#6734856854',
                                            style: AppTextStyles.style14Medium
                                                .copyWith(
                                                  color: colors.onSecondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                      16.hSpace,
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Order Date',
                                              style: AppTextStyles
                                                  .style14Regular
                                                  .copyWith(
                                                    color: colors.onSurface,
                                                  ),
                                            ),
                                          ),
                                          Text(
                                            '12 March 2026',
                                            style: AppTextStyles.style14Medium
                                                .copyWith(
                                                  color: colors.onSecondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                      16.hSpace,
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Payment Method',
                                              style: AppTextStyles
                                                  .style14Regular
                                                  .copyWith(
                                                    color: colors.onSurface,
                                                  ),
                                            ),
                                          ),
                                          Text(
                                            'Cash on Delivery',
                                            style: AppTextStyles.style14Medium
                                                .copyWith(
                                                  color: colors.primary,
                                                ),
                                          ),
                                        ],
                                      ),
                                      16.hSpace,
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Product',
                                              style: AppTextStyles
                                                  .style14Regular
                                                  .copyWith(
                                                    color: colors.onSurface,
                                                  ),
                                            ),
                                          ),
                                          Text(
                                            '1',
                                            style: AppTextStyles.style14Medium
                                                .copyWith(
                                                  color: colors.primary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              /*    color: colors.secondary.withValues(
                                alpha: 0.1,
                              ),*/
                              gradient: screenGradient,
                              borderRadius: AppBorderRadius.brCircular12.r,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Product Information',
                                  style: AppTextStyles.style16SemiBold.copyWith(
                                    color: colors.onSecondary,
                                  ),
                                ),
                                12.hSpace,
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: colors.onPrimary,
                                    borderRadius: AppBorderRadius.brCircular8.r,
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 10,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            AppBorderRadius.brCircular12.r,
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              'https://www.shutterstock.com/image-photo/various-kinds-fresh-colorful-fruits-260nw-2698161807.jpg',
                                          width: 70.w,
                                          height: 70.w,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            AutoSizeText(
                                              'Orange',
                                              style: AppTextStyles.style16Medium
                                                  .copyWith(
                                                    color: colors.onSecondary,
                                                  ),
                                            ),
                                            Row(
                                              spacing: 5,
                                              children: [
                                                AutoSizeText(
                                                  '20.00',
                                                  style: AppTextStyles
                                                      .style14Regular
                                                      .copyWith(
                                                        color: colors.onSecondary,
                                                      ),
                                                ),
                                                Assets
                                                    .media
                                                    .images
                                                    .svg
                                                    .realSaudiCurrency
                                                    .svg(
                                                      width: 12.sp,
                                                      height: 12.sp,
                                                      fit: BoxFit.contain,
                                                      colorFilter:
                                                          ColorFilter.mode(
                                                            colors.onSecondary,
                                                            BlendMode.srcIn,
                                                          ),
                                                    ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 40.h,
                                        child: AutoSizeText(
                                          'x3',
                                          style: AppTextStyles.style16Medium
                                              .copyWith(
                                            color: colors.onSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              /*    color: colors.secondary.withValues(
                                alpha: 0.1,
                              ),*/
                              gradient: screenGradient,
                              borderRadius: AppBorderRadius.brCircular12.r,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Shipping Details',
                                  style: AppTextStyles.style16SemiBold.copyWith(
                                    color: colors.onSecondary,
                                  ),
                                ),
                                12.hSpace,
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: colors.onPrimary,
                                    borderRadius: AppBorderRadius.brCircular8.r,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 44.w,
                                            height: 44.w,
                                            decoration: BoxDecoration(
                                              color: colors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Assets.media.images.svg.marketIcon.svg(
                                                width: 20.w,
                                                height: 20.w,
                                                colorFilter: ColorFilter.mode(
                                                  colors.onPrimary,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                            ),
                                          ),
                                          12.wSpace,
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'From',
                                                  style: AppTextStyles.style12Medium.copyWith(
                                                    color: colors.onSecondary,
                                                  ),
                                                ),
                                                2.hSpace,
                                                Text(
                                                  'Panda Store',
                                                  style: AppTextStyles.style14Medium.copyWith(
                                                    color: colors.onSurface,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 2,
                                        height: 15,
                                        color: colors.onSurface,
                                        margin: EdgeInsetsDirectional.symmetric(
                                          horizontal: 25,
                                          vertical: 5
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 44.w,
                                            height: 44.w,
                                            decoration: BoxDecoration(
                                              color: colors.onSecondaryFixedVariant,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Assets.media.images.svg.locationIcon.svg(
                                                width: 20.w,
                                                height: 20.w,
                                                colorFilter: ColorFilter.mode(
                                                  colors.onSecondary,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                            ),
                                          ),
                                          12.wSpace,
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'To',
                                                  style: AppTextStyles.style12Medium.copyWith(
                                                    color: colors.onSecondary,
                                                  ),
                                                ),
                                                2.hSpace,
                                                Text(
                                                  '7468 Al Olaya, Riyadh',
                                                  style: AppTextStyles.style14Medium.copyWith(
                                                    color: colors.onSurface,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              /*    color: colors.secondary.withValues(
                                alpha: 0.1,
                              ),*/
                              gradient: screenGradient,
                              borderRadius: AppBorderRadius.brCircular12.r,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Store Details',
                                  style: AppTextStyles.style16SemiBold.copyWith(
                                    color: colors.onSecondary,
                                  ),
                                ),
                                12.hSpace,
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: colors.onPrimary,
                                    borderRadius: AppBorderRadius.brCircular8.r,
                                  ),
                                  child: Column(
                                    spacing: 16,
                                    children: [
                                      Row(
                                        spacing: 10,
                                        children: [
                                          CircularBrandLogo(
                                            radius: 25.sp,
                                            logoUrl:
                                            'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                                          ),
                                          Column(
                                            spacing: 5,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              AutoSizeText(
                                                'Panda Store',
                                                style: AppTextStyles.style16Medium.copyWith(
                                                  color: colors.onSecondary,
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                spacing: 5.w,
                                                children: [
                                                  Assets.media.images.svg.timeIcon.svg(
                                                    width: 16.sp,
                                                    colorFilter: ColorFilter.mode(
                                                      colors.onSurface,
                                                      BlendMode.srcIn,
                                                    ),
                                                  ),
                                                  AutoSizeText(
                                                    '٤٠-٥٠ دقيقة',
                                                    style: AppTextStyles.style12Medium.copyWith(
                                                      color: colors.onSurface,
                                                    ),
                                                  ),
                                                  5.wSpace,
                                                  Assets.media.images.svg.locationIcon.svg(
                                                    width: 14.sp,
                                                    colorFilter: ColorFilter.mode(
                                                      colors.onSurface,
                                                      BlendMode.srcIn,
                                                    ),
                                                  ),
                                                  AutoSizeText(
                                                    '٤٠ - ٥٠ كم',
                                                    style: AppTextStyles.style12Medium.copyWith(
                                                      color: colors.onSurface,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      PrimaryAppButton(isFilled: true, title: 'message',prefixIcon: Assets.media.images.svg.messageIcon.svg(),buttonPadding: 8,)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              /*    color: colors.secondary.withValues(
                                alpha: 0.1,
                              ),*/
                              gradient: screenGradient,
                              borderRadius: AppBorderRadius.brCircular12.r,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Payment Method',
                                  style: AppTextStyles.style16SemiBold.copyWith(
                                    color: colors.onSecondary,
                                  ),
                                ),
                                12.hSpace,
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: colors.onPrimary,
                                    borderRadius: AppBorderRadius.brCircular8.r,
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 10,
                                    children: [
                                      Container(
                                        child: CachedNetworkImage(
                                          imageUrl:
                                          'https://cdn-icons-png.flaticon.com/512/5968/5968601.png',
                                          width: 44.w,
                                          height: 44.w,
                                          fit: BoxFit.cover,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle
                                        ),
                                        clipBehavior: Clip.antiAliasWithSaveLayer,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            AutoSizeText(
                                              'Apple Pay',
                                              style: AppTextStyles.style16Medium
                                                  .copyWith(
                                                color: colors.onSecondary,
                                              ),
                                            ),
                                            Row(
                                              spacing: 5,
                                              children: [
                                                AutoSizeText(
                                                  '20.00',
                                                  style: AppTextStyles
                                                      .style14Regular
                                                      .copyWith(
                                                    color: colors.onSurface,
                                                  ),
                                                ),
                                                Assets
                                                    .media
                                                    .images
                                                    .svg
                                                    .realSaudiCurrency
                                                    .svg(
                                                  width: 12.sp,
                                                  height: 12.sp,
                                                  fit: BoxFit.contain,
                                                  colorFilter:
                                                  ColorFilter.mode(
                                                    colors.onSurface,
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              /*    color: colors.secondary.withValues(
                                alpha: 0.1,
                              ),*/
                              gradient: screenGradient,
                              borderRadius: AppBorderRadius.brCircular12.r,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order Summary',
                                  style: AppTextStyles.style16SemiBold.copyWith(
                                    color: colors.onSecondary,
                                  ),
                                ),
                                12.hSpace,
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: colors.onPrimary,
                                    borderRadius: AppBorderRadius.brCircular8.r,
                                  ),
                                  child: Column(
                                    spacing: 10,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Subtotal',
                                              style: AppTextStyles
                                                  .style14Medium
                                                  .copyWith(
                                                color: colors.onSecondary,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            spacing: 5,
                                            children: [
                                              AutoSizeText(
                                                '10.00',
                                                style: AppTextStyles
                                                    .style14Bold
                                                    .copyWith(
                                                  color: colors.onSecondary,
                                                ),
                                              ),
                                              Assets
                                                  .media
                                                  .images
                                                  .svg
                                                  .realSaudiCurrency
                                                  .svg(
                                                width: 15.sp,
                                                height: 15.sp,
                                                fit: BoxFit.contain,
                                                colorFilter:
                                                ColorFilter.mode(
                                                  colors.onSecondary,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Value Added Tax (VAT) (5%)',
                                              style: AppTextStyles
                                                  .style14Medium
                                                  .copyWith(
                                                color: colors.onSecondary,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            spacing: 5,
                                            children: [
                                              AutoSizeText(
                                                '10.00',
                                                style: AppTextStyles
                                                    .style14Bold
                                                    .copyWith(
                                                  color: colors.onSecondary,
                                                ),
                                              ),
                                              Assets
                                                  .media
                                                  .images
                                                  .svg
                                                  .realSaudiCurrency
                                                  .svg(
                                                width: 15.sp,
                                                height: 15.sp,
                                                fit: BoxFit.contain,
                                                colorFilter:
                                                ColorFilter.mode(
                                                  colors.onSecondary,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Shipping Fees',
                                              style: AppTextStyles
                                                  .style14Medium
                                                  .copyWith(
                                                color: colors.onSecondary,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            spacing: 5,
                                            children: [
                                              AutoSizeText(
                                                '10.00',
                                                style: AppTextStyles
                                                    .style14Bold
                                                    .copyWith(
                                                  color: colors.onSecondary,
                                                ),
                                              ),
                                              Assets
                                                  .media
                                                  .images
                                                  .svg
                                                  .realSaudiCurrency
                                                  .svg(
                                                width: 15.sp,
                                                height: 15.sp,
                                                fit: BoxFit.contain,
                                                colorFilter:
                                                ColorFilter.mode(
                                                  colors.onSecondary,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Discount',
                                              style: AppTextStyles
                                                  .style14Medium
                                                  .copyWith(
                                                color: colors.onSecondary,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            spacing: 5,
                                            children: [
                                              AutoSizeText(
                                                '10.00',
                                                style: AppTextStyles
                                                    .style14Bold
                                                    .copyWith(
                                                  color: colors.errorContainer,
                                                ),
                                              ),
                                              Assets
                                                  .media
                                                  .images
                                                  .svg
                                                  .realSaudiCurrency
                                                  .svg(
                                                width: 15.sp,
                                                height: 15.sp,
                                                fit: BoxFit.contain,
                                                colorFilter:
                                                ColorFilter.mode(
                                                  colors.errorContainer,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        color: colors.inversePrimary,
                                        thickness: 0.5,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Total',
                                              style: AppTextStyles
                                                  .style14SemiBold
                                                  .copyWith(
                                                color: colors.onSecondary,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            spacing: 5,
                                            children: [
                                              AutoSizeText(
                                                '10.00',
                                                style: AppTextStyles
                                                    .style14Bold
                                                    .copyWith(
                                                  color: colors.primary,
                                                ),
                                              ),
                                              Assets
                                                  .media
                                                  .images
                                                  .svg
                                                  .realSaudiCurrency
                                                  .svg(
                                                width: 15.sp,
                                                height: 15.sp,
                                                fit: BoxFit.contain,
                                                colorFilter:
                                                ColorFilter.mode(
                                                  colors.primary,
                                                  BlendMode.srcIn,
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
                          ),
                        ],
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
