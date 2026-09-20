import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/params/online_card_params.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/lists/delete_swipe_background.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/online_card_radio_selector_item.dart';

/// The saved-cards list: a radio-style selector where the highlighted card is
/// the default one.
///
/// Selection is **data-driven** — a card is shown selected when its
/// [OnlineCardParams.isDefault] is set — so it always reflects the real default
/// rather than transient local state. Tapping a card fires [onCardSelected]
/// (the caller makes it the default); swiping fires [onDeleteCard]. Both are
/// reconciled by refetching the list, so this widget holds no state of its own.
class OnlineCardRadioSelector extends StatelessWidget {
  const OnlineCardRadioSelector({
    super.key,
    required this.cards,
    this.onCardSelected,
    this.onDeleteCard,
    this.onEditCard,
  });

  final List<OnlineCardParams> cards;

  /// Fired when a card is tapped. Wire this to the set-default VM: the tapped
  /// card becomes the default and the highlight follows [OnlineCardParams.isDefault].
  final ValueChanged<OnlineCardParams>? onCardSelected;

  /// Fired when a card is swiped away. Wire this to the delete-card VM: the card
  /// springs back into place and is removed only once the VM refetches the list
  /// on a confirmed server delete (see [_confirmDelete]).
  final ValueChanged<OnlineCardParams>? onDeleteCard;

  /// Fired when a card's "Edit" button is tapped. Wire this to open the edit
  /// sheet for that card.
  final ValueChanged<OnlineCardParams>? onEditCard;

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
            // An unusable card can't be made the default — the server rejects
            // it — so the row takes no tap at all rather than rippling into a
            // call that does nothing. Swiping it away still works: an expired
            // card is exactly the one a customer wants to delete.
            onTap: card.isUsable ? () => onCardSelected?.call(card) : null,
            child: OnlineCardRadioSelectorItem(
              cardItem: card,
              isSelected: card.isDefault,
              onEdit: onEditCard == null ? null : () => onEditCard!(card),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => 10.hSpace,
      itemCount: cards.length,
    );
  }

  /// Swiping a card fires the delete but never dismisses the card itself:
  /// returning `false` springs it back into place, and the view model removes it
  /// (by refetching the list) only once the server confirms the delete. So the
  /// card stays on screen until the delete-card VM succeeds.
  Future<bool> _confirmDelete(OnlineCardParams card) async {
    onDeleteCard?.call(card);
    return false;
  }
}
