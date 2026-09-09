import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/params/online_card_params.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/lists/delete_swipe_background.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/online_card_radio_selector_item.dart';

class OnlineCardRadioSelector extends StatefulWidget {
  const OnlineCardRadioSelector({
    super.key,
    required this.cards,
    this.onAmountChanged,
    this.onDeleteCard,
  });
  final List<OnlineCardParams> cards;
  final ValueChanged<OnlineCardParams?>? onAmountChanged;

  /// Fired when a card is swiped away. Wire this to the delete-card VM provider:
  /// the card springs back into place and is removed only once the VM refetches
  /// the list on a confirmed server delete (see [_confirmDelete]).
  final ValueChanged<OnlineCardParams>? onDeleteCard;

  @override
  State<OnlineCardRadioSelector> createState() =>
      _OnlineCardRadioSelectorState();
}

class _OnlineCardRadioSelectorState extends State<OnlineCardRadioSelector> {
  late OnlineCardParams selectedCard;

  @override
  void initState() {
    super.initState();
    selectedCard = widget.cards.first;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final OnlineCardParams card = widget.cards[index];
        return Dismissible(
          key: ValueKey<String>(card.cardNumber),
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
            onTap: () {
              selectedCard = card;
              widget.onAmountChanged?.call(selectedCard);
              setState(() {});
            },
            child: OnlineCardRadioSelectorItem(
              cardItem: card,
              isSelected: selectedCard == card,
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => 10.hSpace,
      itemCount: widget.cards.length,
    );
  }

  /// Swiping a card fires the delete but never dismisses the card itself:
  /// returning `false` springs it back into place, and the view model removes it
  /// (by refetching the list) only once the server confirms the delete. So the
  /// card stays on screen until the delete-card VM succeeds.
  Future<bool> _confirmDelete(OnlineCardParams card) async {
    widget.onDeleteCard?.call(card);
    return false;
  }
}
