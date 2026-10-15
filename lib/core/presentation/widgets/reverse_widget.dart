import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';

class ReverseWidget extends StatelessWidget {
  const ReverseWidget({
    super.key,
    required this.child, this.applyReverse,
  });

  final bool? applyReverse;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // A Transform either way (identity costs no layer): returning the bare
    // child when unmirrored remounted it on every language switch, so stateful
    // children such as the Home header's animated motorcycle reloaded.
    return Transform.flip(flipX: applyReverse ?? context.isRTL, child: child);
  }
}