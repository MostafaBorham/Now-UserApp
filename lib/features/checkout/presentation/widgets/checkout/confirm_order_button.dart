import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';

/// The checkout screen's confirm button. Kept stateless and provider-free on
/// purpose: no `ref.watch` means it's built once with the body and never
/// rebuilds — not when the draft resolves, not while the confirm request is in
/// flight. Loading/enabled feedback lives elsewhere (e.g. the screen's
/// `ref.listen` on the confirm result surfacing errors via snackbar).
class ConfirmOrderButton extends StatelessWidget {
  const ConfirmOrderButton({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return PrimaryAppButton(title: 'Confirm Order', onTap: onConfirm);
  }
}
