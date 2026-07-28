import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_add_to_cart_button.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_cart_counter_view.dart';

class AnimatedCartButton extends StatefulWidget {
  const AnimatedCartButton({super.key});

  @override
  State<AnimatedCartButton> createState() =>
      _AnimatedCartButtonState();
}

class _AnimatedCartButtonState extends State<AnimatedCartButton> {
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
            child: AnimatedCartCounterView(
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
            child: AnimatedAddToCartButton(
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
