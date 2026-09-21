import 'package:flutter/widgets.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// The status of a wallet transaction, modeled as a sealed hierarchy so callers
/// branch over an exhaustive, type-safe set instead of loose raw strings.
///
/// [name] carries the raw value the API sends in the transaction's `status`
/// field. The status-chip background ([statusColor]), status label color
/// ([statusTextColor]) and amount color ([priceColor]) are resolved from the
/// theme so the mapping from a status to its colors lives in one place instead
/// of being re-hardcoded per call site.
///
/// Parse the API value with [WalletTransactionStatus.fromStatus]; a `null`,
/// empty, or unrecognized value falls back to [WalletUnknownTransactionStatus]
/// carrying the raw value.
sealed class WalletTransactionStatus {
  const WalletTransactionStatus(this.name);

  /// The raw value the API sends in the transaction's `status` field.
  final String name;

  /// Maps the API `status` value onto its [WalletTransactionStatus]. A `null`,
  /// empty, or unrecognized value resolves to [WalletUnknownTransactionStatus]
  /// carrying the raw value.
  static WalletTransactionStatus fromStatus(String? status) => switch (status) {
    'pending' => const WalletPendingTransactionStatus(),
    'successful' => const WalletSuccessfulTransactionStatus(),
    'failed' => const WalletFailedTransactionStatus(),
    'refunded' => const WalletRefundedTransactionStatus(),
    _ => WalletUnknownTransactionStatus(status ?? ''),
  };

  /// Background of the status chip.
  Color statusColor(AppColorScheme colors) => switch (this) {
    WalletPendingTransactionStatus() => colors.orange100,
    WalletSuccessfulTransactionStatus() ||
    WalletRefundedTransactionStatus() => colors.primary500Main.withValues(
      alpha: 0.1,
    ),
    WalletFailedTransactionStatus() ||
    WalletUnknownTransactionStatus() => colors.errorContainer.withValues(alpha: 0.1),
  };

  /// Color of the status label inside the chip.
  Color statusTextColor(AppColorScheme colors) => switch (this) {
    WalletPendingTransactionStatus() => colors.orange900,
    WalletSuccessfulTransactionStatus() ||
    WalletRefundedTransactionStatus() => colors.primary500Main,
    WalletFailedTransactionStatus() ||
    WalletUnknownTransactionStatus() => colors.errorContainer,
  };

  /// Color of the transaction amount.
  Color priceColor(AppColorScheme colors) => switch (this) {
    WalletPendingTransactionStatus() => colors.orange500,
    WalletSuccessfulTransactionStatus() ||
    WalletRefundedTransactionStatus() => colors.primary500Main,
    WalletFailedTransactionStatus() ||
    WalletUnknownTransactionStatus() => colors.errorContainer,
  };
}

/// Awaiting completion.
final class WalletPendingTransactionStatus extends WalletTransactionStatus {
  const WalletPendingTransactionStatus() : super('pending');
}

/// Completed successfully.
final class WalletSuccessfulTransactionStatus extends WalletTransactionStatus {
  const WalletSuccessfulTransactionStatus() : super('successful');
}

/// Failed to complete.
final class WalletFailedTransactionStatus extends WalletTransactionStatus {
  const WalletFailedTransactionStatus() : super('failed');
}

/// Reversed back to the wallet.
final class WalletRefundedTransactionStatus extends WalletTransactionStatus {
  const WalletRefundedTransactionStatus() : super('refunded');
}

/// Any status the app doesn't model yet; carries the raw value for display and
/// reuses the error palette so an unexpected state never renders unstyled.
final class WalletUnknownTransactionStatus extends WalletTransactionStatus {
  const WalletUnknownTransactionStatus(super.name);
}
