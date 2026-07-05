// /// "Another Payment Method" section — wallet-style options (Apple Pay, STC Pay)
// /// that share the same single selection as the saved cards.
// class AnotherPaymentMethodSection extends StatelessWidget {
//   const AnotherPaymentMethodSection({
//     super.key,
//     required this.selected,
//     required this.onSelect,
//   });

//   final PaymentOption selected;
//   final ValueChanged<PaymentOption> onSelect;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SectionTitle(LangKeys.anotherPaymentMethodKey.tr()),
//         const SizedBox(height: 16),
//         PaymentOptionTile(
//           leading: Assets.media.images.svg.applePay.svg(),
//           title: LangKeys.applePayKey.tr(),
//           isSelected: selected == PaymentOption.applePay,
//           onTap: () => onSelect(PaymentOption.applePay),
//         ),
//         const SizedBox(height: 12),
//         PaymentOptionTile(
//           leading: Assets.media.images.svg.stc.svg(),
//           title: LangKeys.stcPayKey.tr(),
//           isSelected: selected == PaymentOption.stcPay,
//           onTap: () => onSelect(PaymentOption.stcPay),
//         ),
//       ],
//     );
//   }
// }
