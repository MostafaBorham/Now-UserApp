import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';

/// The four milestones a live order is drawn with, in
/// `OrderStatus.stepStatusAt` order. Shared by the home live-orders strip and
/// the tray card so the two always agree.
const List<String> liveOrderStepKeys = <String>[
  LangKeys.orderAcceptedKey,
  LangKeys.preparingKey,
  LangKeys.onTheWayKey,
  LangKeys.deliveredKey,
];

/// Minutes from now until [isoTimestamp] (never negative), or `null` when the
/// order carries no parseable estimate.
int? minutesUntil(String? isoTimestamp) {
  final DateTime? target = DateTime.tryParse(isoTimestamp ?? '');
  if (target == null) return null;
  final int minutes = target.difference(DateTime.now()).inMinutes;
  return minutes < 0 ? 0 : minutes;
}
