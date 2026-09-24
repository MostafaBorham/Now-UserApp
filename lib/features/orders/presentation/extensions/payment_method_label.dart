import 'package:easy_localization/easy_localization.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';

/// The customer-facing name of an order's `payment_method` key (`wallet`,
/// `card`, `cod` — the three the place endpoint accepts), shared by Order
/// Details and Track Order so neither prints the raw key.
extension PaymentMethodLabel on OrderModel {
  String get paymentMethodLabel => switch (paymentMethod) {
    'wallet' => LangKeys.walletKey.tr(),
    'card' => LangKeys.paymentCardKey.tr(),
    'cod' => LangKeys.cashOnDeliveryKey.tr(),
    _ => paymentMethod ?? '',
  };
}
