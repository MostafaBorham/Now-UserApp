import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/params/online_card_params.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/lists/delete_swipe_background.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/online_card_radio_selector_item.dart';









class OnlineCardRadioSelector extends StatelessWidget {
  const OnlineCardRadioSelector({
    super.key,
    required this.cards,
    this.onCardSelected,
    this.onDeleteCard,
  });

  final List<OnlineCardParams> cards;



  final ValueChanged<OnlineCardParams>? onCardSelected;




  final ValueChanged<OnlineCardParams>? onDeleteCard;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final OnlineCardParams card = cards[index];
        return Dismissible(
          key: ValueKey<Object>(card.id ?? card.cardNumber),
          direction: DismissDirection.horizontal,
          background: DeleteSwipeBackground(
            alignment: AlignmentDirectional.centerStart,
            borderRadius: AppBorderRadius.brCircular12,
          ),
          secondaryBackground: DeleteSwipeBackground(
            alignment: AlignmentDirectional.centerEnd,
            borderRadius: AppBorderRadius.brCircular12,
          ),
          confirmDismiss: (_) => _confirmDelete(card),
          child: InkWell(
            onTap: () => onCardSelected?.call(card),
            child: OnlineCardRadioSelectorItem(
              cardItem: card,
              isSelected: card.isDefault,
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => 10.hSpace,
      itemCount: cards.length,
    );
  }





  Future<bool> _confirmDelete(OnlineCardParams card) async {
    onDeleteCard?.call(card);
    return false;
  }
}
