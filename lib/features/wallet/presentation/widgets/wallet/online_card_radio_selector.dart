import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/common/params/online_card_params.dart';
import 'package:nowdelivery_user_app/common/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/features/wallet/presentation/widgets/wallet/online_card_radio_selector_item.dart';

class OnlineCardRadioSelector extends StatefulWidget {
  const OnlineCardRadioSelector({super.key, required this.cards, this.onAmountChanged});
  final List<OnlineCardParams> cards;
  final ValueChanged<OnlineCardParams?>? onAmountChanged;
  @override
  State<OnlineCardRadioSelector> createState() => _OnlineCardRadioSelectorState();
}

class _OnlineCardRadioSelectorState extends State<OnlineCardRadioSelector> {
  late OnlineCardParams selectedCard;

  @override
  void initState() {
    super.initState();
    selectedCard =widget.cards.first;
  }
  @override
  Widget build(BuildContext context) {
    return ListView.separated(shrinkWrap: true ,padding: EdgeInsets.zero, itemBuilder: (context, index) {
      return InkWell(
          onTap: () {
            selectedCard = widget.cards[index];
            widget.onAmountChanged?.call(selectedCard);
            setState(() {
            });
          },
          child: OnlineCardRadioSelectorItem(cardItem: widget.cards[index], isSelected: selectedCard == widget.cards[index]));
    }, separatorBuilder: (context, index) => 10.hSpace, itemCount: widget.cards.length);
  }
}

