

import 'package:easy_localization/easy_localization.dart' as _;
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/overlay_opacity_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';



const double _ticketWidth = 121;
const double _ticketHeight = 158;
const double _headHeight = 60;
const double _notchSize = 32;




const double _bodyHPadding = 8;
const double _notchOverlap = _notchSize / 2 - _bodyHPadding;


const List<Color> _creamBody = [Color(0xffFEFAEA), Color(0xffFEF4D0)];
const List<Color> _greenBody = [Color(0xffF4FAF3), Color(0xffE8F5E7)];


const double _selectedOpacity = 0.15;









class VoucherTicket extends StatelessWidget {
  const VoucherTicket({
    super.key,
    required this.discountValue,
    this.name,
    this.validityText = '',
    this.isPercentage = true,
    this.darkHead = false,
    this.isSelected = false,
    this.isDimmed = false,
    this.onTap,
  });




  final String discountValue;


  final bool isPercentage;


  final String? name;


  final String validityText;


  final bool darkHead;


  final bool isSelected;


  final bool isDimmed;


  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    final Color headColor = darkHead
        ? colors.surfaceBright
        : colors.onSecondaryFixedVariant;
    final Color discountColor = darkHead
        ? colors.onSecondaryFixedVariant
        : colors.primaryContainer;
    final Color nameColor = darkHead
        ? colors.white
        : colors.tertiaryContainer;
    final String? couponName = name?.isNotEmpty ?? false ? name : null;

    return OverlayOpacityWidget(
      disabled: isDimmed,
      child: InkWell(
        onTap: onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: isSelected ? _selectedOpacity : 1,
          child: Container(
            width: _ticketWidth,



            constraints: const BoxConstraints(minHeight: _ticketHeight),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: AppBorderRadius.brCircular16),
            child: Column(
              children: [
                Container(
                  constraints: const BoxConstraints(minHeight: _headHeight),
                  width: double.infinity,
                  color: headColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 2,
                    children: [
                      isPercentage
                          ? Text(
                              '$discountValue%',
                              textDirection: TextDirection.ltr,
                              style: AppTextStyles.style20SemiBold.copyWith(
                                color: discountColor,
                                height: 1,
                              ),
                            )
                          : NewPriceWidget(
                              color: discountColor,
                              price: discountValue,
                              size: 20,
                            ),
                      if (couponName != null)
                        Text(
                          couponName,
                          textAlign: TextAlign.center,


                          overflow: TextOverflow.visible,
                          style: AppTextStyles.style12SemiBold.copyWith(
                            color: nameColor,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(


                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          left: _bodyHPadding,
                          right: _bodyHPadding,
                          top: 10,
                          bottom: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: darkHead ? _creamBody : _greenBody,
                          ),
                        ),



                        child: Column(
                          children: [
                            Text(
                              LangKeys.purchaseVoucherKey.tr(),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,


                              style: AppTextStyles.style16Medium.copyWith(
                                color: colors.primaryContainer,
                                height: 1,
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: validityText.isEmpty
                                    ? const SizedBox.shrink()
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: _notchOverlap,
                                        ),
                                        child: Text(
                                          validityText,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.visible,
                                          style: AppTextStyles.style10Medium
                                              .copyWith(
                                                color: colors.neutral500,
                                                height: 1,
                                              ),
                                        ),
                                      ),
                              ),
                            ),
                            if (validityText.isNotEmpty)
                              const SizedBox(height: 8),
                            Assets.media.images.svg.appLogo.svg(width: 64),
                          ],
                        ),
                      ),



                      Positioned(
                        left: -_notchSize / 2,
                        top: 0,
                        bottom: 0,
                        child: Center(child: _notch(context)),
                      ),
                      Positioned(
                        right: -_notchSize / 2,
                        top: 0,
                        bottom: 0,
                        child: Center(child: _notch(context)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _notch(BuildContext context) => Container(
    width: _notchSize,
    height: _notchSize,
    decoration: BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
      shape: BoxShape.circle,
    ),
  );
}
