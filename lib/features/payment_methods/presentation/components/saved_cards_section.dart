// /// "Saved Cards" section — the user's stored cards, with the currently
// /// selected one marked.
// class SavedCardsSection extends StatelessWidget {
//   const SavedCardsSection({
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
//         SectionTitle(LangKeys.savedCardsKey.tr()),
//         const SizedBox(height: 16),
//         PaymentOptionTile(
//           leading: Assets.media.images.svg.blueCircle.svg(),
//           title: 'Visa ****4587',
//           subtitle: LangKeys.defaultCardKey.tr(),
//           isSelected: selected == PaymentOption.visa,
//           onTap: () => onSelect(PaymentOption.visa),
//         ),
//         const SizedBox(height: 12),
//         PaymentOptionTile(
//           leading: Assets.media.images.svg.masterCardCircle.svg(),
//           title: 'Master Card ****4874',
//           isSelected: selected == PaymentOption.masterCard,
//           onTap: () => onSelect(PaymentOption.masterCard),
//         ),
//       ],
//     );
//   }
// }
