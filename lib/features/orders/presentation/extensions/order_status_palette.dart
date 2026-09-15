import 'package:flutter/widgets.dart';
import 'package:nowdelivery_user_app/core/enums/order_status.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';







extension OrderStatusPalette on OrderStatus {
  ({Color background, Color foreground}) palette(AppColorScheme colors) =>
      switch (this) {
        AcceptedStatus() => (
          background: colors.sky500.withValues(alpha: 0.15),
          foreground: colors.sky500,
        ),
        OnTheWayStatus() => (
          background: colors.tertiaryFixed,
          foreground: colors.orange500,
        ),
        DeliveredStatus() => (
          background: colors.primary100,
          foreground: colors.primary500Main,
        ),
        CancelledStatus() => (
          background: colors.onError.withValues(alpha: 0.15),
          foreground: colors.onError,
        ),
        RefundedStatus() => (
          background: colors.orange100,
          foreground: colors.deepOrange400,
        ),
        PendingStatus() ||
        PreparingStatus() ||
        ReadyStatus() ||
        UnknownStatus() => (
          background: colors.tertiaryFixed,
          foreground: colors.onErrorContainer,
        ),
      };
}
