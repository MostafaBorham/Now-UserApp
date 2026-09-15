import 'package:flutter/widgets.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';













sealed class WalletTransactionStatus {
  const WalletTransactionStatus(this.name);


  final String name;




  static WalletTransactionStatus fromStatus(String? status) => switch (status) {
    'pending' => const WalletPendingTransactionStatus(),
    'successful' => const WalletSuccessfulTransactionStatus(),
    'failed' => const WalletFailedTransactionStatus(),
    'refunded' => const WalletRefundedTransactionStatus(),
    _ => WalletUnknownTransactionStatus(status ?? ''),
  };


  Color statusColor(AppColorScheme colors) => switch (this) {
    WalletPendingTransactionStatus() => colors.orange100,
    WalletSuccessfulTransactionStatus() => colors.primary500Main.withValues(
      alpha: 0.1,
    ),
    WalletFailedTransactionStatus() ||
    WalletRefundedTransactionStatus() ||
    WalletUnknownTransactionStatus() => colors.errorContainer.withValues(alpha: 0.1),
  };


  Color statusTextColor(AppColorScheme colors) => switch (this) {
    WalletPendingTransactionStatus() => colors.orange900,
    WalletSuccessfulTransactionStatus() => colors.primary500Main,
    WalletFailedTransactionStatus() ||
    WalletRefundedTransactionStatus() ||
    WalletUnknownTransactionStatus() => colors.errorContainer,
  };


  Color priceColor(AppColorScheme colors) => switch (this) {
    WalletPendingTransactionStatus() => colors.orange500,
    WalletSuccessfulTransactionStatus() => colors.primary500Main,
    WalletFailedTransactionStatus() ||
    WalletRefundedTransactionStatus() ||
    WalletUnknownTransactionStatus() => colors.errorContainer,
  };
}


final class WalletPendingTransactionStatus extends WalletTransactionStatus {
  const WalletPendingTransactionStatus() : super('pending');
}


final class WalletSuccessfulTransactionStatus extends WalletTransactionStatus {
  const WalletSuccessfulTransactionStatus() : super('successful');
}


final class WalletFailedTransactionStatus extends WalletTransactionStatus {
  const WalletFailedTransactionStatus() : super('failed');
}


final class WalletRefundedTransactionStatus extends WalletTransactionStatus {
  const WalletRefundedTransactionStatus() : super('refunded');
}



final class WalletUnknownTransactionStatus extends WalletTransactionStatus {
  const WalletUnknownTransactionStatus(super.name);
}
