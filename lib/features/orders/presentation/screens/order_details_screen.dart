import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/route/app_routes.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_button.dart';

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
      colors: [
        colors.onTertiaryFixedVariant,
        colors.onSurfaceVariant.withValues(alpha: 0.3),
      ],
    );
    return Scaffold(
      body: AppWavedScaffold(
        body: SingleChildScrollView(
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
                          colors.tertiaryContainer,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LangKeys.orderNumberKey.tr(),
                          style: AppTextStyles.style12Medium.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                        Text(
                          'Order #458741',
                          style: AppTextStyles.style18SemiBold.copyWith(
                            color: colors.onSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: AppBorderRadius.brCircular20.r,
                    ),
                    child: Text(
                      LangKeys.deliveredKey.tr(),
                      style: AppTextStyles.style12Medium.copyWith(
                        color: colors.primary,
                      ),
                    ),
                  ),
                  /*Column(
                    spacing: 10,
                    children: [
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: colors.onPrimary,
                            builder: (context) => OrderRateView(),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: AppBorderRadius.brCircular8,
                          ),
                          child: Row(
                            spacing: 5,
                            children: [
                              Assets.media.images.svg.starOutlineIcon.svg(
                                width: 12.sp,
                                colorFilter: ColorFilter.mode(
                                  colors.onPrimary,
                                  BlendMode.srcIn,
                                ),
                              ),
                              Text(
                                'Rate',
                                style: AppTextStyles.style14Medium.copyWith(
                                  color: colors.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 5.h,
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
                  ),*/
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
                      LangKeys.generalInformationKey.tr(),
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
                                  LangKeys.orderNumberKey.tr(),
                                  style: AppTextStyles.style14Regular.copyWith(
                                    color: colors.onSurface,
                                  ),
                                ),
                              ),
                              Text(
                                '#6734856854',
                                style: AppTextStyles.style14Medium.copyWith(
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
                                  LangKeys.orderDateKey.tr(),
                                  style: AppTextStyles.style14Regular.copyWith(
                                    color: colors.onSurface,
                                  ),
                                ),
                              ),
                              Text(
                                '12 March 2026',
                                style: AppTextStyles.style14Medium.copyWith(
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
                                  LangKeys.paymentMethodKey.tr(),
                                  style: AppTextStyles.style14Regular.copyWith(
                                    color: colors.onSurface,
                                  ),
                                ),
                              ),
                              Text(
                                LangKeys.cashOnDeliveryKey.tr(),
                                style: AppTextStyles.style14Medium.copyWith(
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
                                  LangKeys.productKey.tr(),
                                  style: AppTextStyles.style14Regular.copyWith(
                                    color: colors.onSurface,
                                  ),
                                ),
                              ),
                              Text(
                                '1',
                                style: AppTextStyles.style14Medium.copyWith(
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
                      LangKeys.itemInformationKey.tr(),
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
                            borderRadius: AppBorderRadius.brCircular12.r,
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
                                  style: AppTextStyles.style16Medium.copyWith(
                                    color: colors.onSecondary,
                                  ),
                                ),
                                Row(
                                  spacing: 5,
                                  children: [
                                    Assets.media.images.svg.realSaudiCurrency
                                        .svg(
                                          width: 12.sp,
                                          height: 12.sp,
                                          fit: BoxFit.contain,
                                          colorFilter: ColorFilter.mode(
                                            colors.onSecondary,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                    AutoSizeText(
                                      '20.00',
                                      style: AppTextStyles.style14Regular
                                          .copyWith(color: colors.onSecondary),
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
                              style: AppTextStyles.style16Medium.copyWith(
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
                      LangKeys.deliveryDetailsKey.tr(),
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
                                      LangKeys.fromKey.tr(),
                                      style: AppTextStyles.style12Medium
                                          .copyWith(color: colors.onSecondary),
                                    ),
                                    2.hSpace,
                                    Text(
                                      'Panda Store',
                                      style: AppTextStyles.style14Medium
                                          .copyWith(color: colors.onSurface),
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
                              vertical: 5,
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
                                  child: Assets.media.images.svg.locationIcon
                                      .svg(
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
                                      LangKeys.toKey.tr(),
                                      style: AppTextStyles.style12Medium
                                          .copyWith(color: colors.onSecondary),
                                    ),
                                    2.hSpace,
                                    Text(
                                      '7468 Al Olaya, Riyadh',
                                      style: AppTextStyles.style14Medium
                                          .copyWith(color: colors.onSurface),
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
              PrimaryButton(
                title: LangKeys.submitAComplaintKey.tr(),
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.fileComplaintScreen),
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
                      LangKeys.paymentMethodKey.tr(),
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
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                  'Apple Pay',
                                  style: AppTextStyles.style16Medium.copyWith(
                                    color: colors.onSecondary,
                                  ),
                                ),
                                Row(
                                  spacing: 5,
                                  children: [
                                    Assets.media.images.svg.realSaudiCurrency
                                        .svg(
                                          width: 12.sp,
                                          height: 12.sp,
                                          fit: BoxFit.contain,
                                          colorFilter: ColorFilter.mode(
                                            colors.onSurface,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                    AutoSizeText(
                                      '20.00',
                                      style: AppTextStyles.style14Regular
                                          .copyWith(color: colors.onSurface),
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
                  spacing: 12,
                  children: [
                    Text(
                      LangKeys.invoiceSummaryKey.tr(),
                      style: AppTextStyles.style16SemiBold.copyWith(
                        color: colors.onSecondary,
                      ),
                    ),
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
                                  LangKeys.subtotalKey.tr(),
                                  style: AppTextStyles.style14Regular.copyWith(
                                    color: colors.onSecondary,
                                  ),
                                ),
                              ),
                              Row(
                                spacing: 5,
                                children: [
                                  Assets.media.images.svg.realSaudiCurrency.svg(
                                    width: 15.sp,
                                    height: 15.sp,
                                    fit: BoxFit.contain,
                                    colorFilter: ColorFilter.mode(
                                      colors.onSecondary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  AutoSizeText(
                                    '10',
                                    style: AppTextStyles.style14Bold.copyWith(
                                      color: colors.onSecondary,
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
                                  LangKeys.vatFivePercentKey.tr(),
                                  style: AppTextStyles.style14Regular.copyWith(
                                    color: colors.onSecondary,
                                  ),
                                ),
                              ),
                              Row(
                                spacing: 5,
                                children: [
                                  Assets.media.images.svg.realSaudiCurrency.svg(
                                    width: 15.sp,
                                    height: 15.sp,
                                    fit: BoxFit.contain,
                                    colorFilter: ColorFilter.mode(
                                      colors.onSecondary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  AutoSizeText(
                                    '10',
                                    style: AppTextStyles.style14Bold.copyWith(
                                      color: colors.onSecondary,
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
                                  LangKeys.deliveryFeesKey.tr(),
                                  style: AppTextStyles.style14Regular.copyWith(
                                    color: colors.onSecondary,
                                  ),
                                ),
                              ),
                              Row(
                                spacing: 5,
                                children: [
                                  Assets.media.images.svg.realSaudiCurrency.svg(
                                    width: 15.sp,
                                    height: 15.sp,
                                    fit: BoxFit.contain,
                                    colorFilter: ColorFilter.mode(
                                      colors.onSecondary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  AutoSizeText(
                                    '10',
                                    style: AppTextStyles.style14Bold.copyWith(
                                      color: colors.onSecondary,
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
                                  LangKeys.discountLabelKey.tr(),
                                  style: AppTextStyles.style14Regular.copyWith(
                                    color: colors.onSecondary,
                                  ),
                                ),
                              ),
                              Row(
                                spacing: 5,
                                children: [
                                  Assets.media.images.svg.realSaudiCurrency.svg(
                                    width: 15.sp,
                                    height: 15.sp,
                                    fit: BoxFit.contain,
                                    colorFilter: ColorFilter.mode(
                                      colors.onError,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  AutoSizeText(
                                    '10',
                                    style: AppTextStyles.style14Bold.copyWith(
                                      color: colors.onError,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Divider(color: colors.inversePrimary, thickness: 0.5),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  LangKeys.totalKey.tr(),
                                  style: AppTextStyles.style14SemiBold.copyWith(
                                    color: colors.onSecondary,
                                  ),
                                ),
                              ),
                              Row(
                                spacing: 5,
                                children: [
                                  Assets.media.images.svg.realSaudiCurrency.svg(
                                    width: 15.sp,
                                    height: 15.sp,
                                    fit: BoxFit.contain,
                                    colorFilter: ColorFilter.mode(
                                      colors.primary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  AutoSizeText(
                                    '10',
                                    style: AppTextStyles.style14Bold.copyWith(
                                      color: colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PrimaryAppButton(title: LangKeys.printInvoiceKey.tr()),
                  ],
                ),
              ),
            ],
          ),
        ),
        appBarTitle: LangKeys.orderDetailsKey.tr(),
        canPop: true,
        appBarActions: [
          CircleAvatar(
            backgroundColor: colors.onPrimary,
            radius: MediaQuery.sizeOf(context).width*0.05,
            child: Assets.media.images.svg.supportCallIcon.svg(
              width: MediaQuery.sizeOf(context).width*0.05,
              colorFilter: ColorFilter.mode(
                colors.onSecondary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
