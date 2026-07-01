import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/buttons/primary_item_quantity_button/add_to_cart_button.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/buttons/primary_item_quantity_button/add_to_cart_counter_widget.dart';

class PrimaryItemQuantityButton extends StatefulWidget {
  const PrimaryItemQuantityButton({super.key});

  @override
  State<PrimaryItemQuantityButton> createState() =>
      _PrimaryItemQuantityButtonState();
}

class _PrimaryItemQuantityButtonState extends State<PrimaryItemQuantityButton> {
  bool showAddToCartCounter = false;
  int counter = 0;
  bool isRotate = false;
  Timer? _timer;

  void startTimer() {
    _timer?.cancel();

    _timer = Timer(const Duration(seconds: 2), () {
      showAddToCartCounter = false;
      isRotate = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return showAddToCartCounter
        ? AnimatedScale(
            scale: showAddToCartCounter ? 1 : 0,
            duration: const Duration(seconds: 2),
            curve: Curves.linear,
            onEnd: () {},
            child: AddToCartCounterWidget(
              counter: counter,
              onInc: () {
                startTimer();
                counter++;
                setState(() {});
              },
              onDec: () {
                startTimer();
                counter--;
                setState(() {});
              },
              onDelete: () {
                showAddToCartCounter = false;
                counter--;
                isRotate = false;
                setState(() {});
              },
            ),
          )
        : InkWell(
            onTap: () {
              isRotate = !isRotate;
              setState(() {});
            },
            child: AddToCartButton(
              text: counter < 1 ? '+' : counter.toString(),
              onEnd: () {
                startTimer();
                if (counter < 1) counter++;
                showAddToCartCounter = true;
                setState(() {});
              },
              isRotate: isRotate,
            ),
          );
  }
}
