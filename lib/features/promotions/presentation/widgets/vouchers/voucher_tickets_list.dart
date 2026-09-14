import 'package:flutter/material.dart';

/// The shared horizontal voucher-ticket row used across the app (store details
/// and checkout). It owns only the layout — a horizontally scrolling row of
/// [VoucherTicket]s with 16px gaps — while each call site builds the tickets
/// and owns their tap/select behaviour through [itemBuilder].
///
/// Tickets grow to fit their full (un-truncated) text, so heights differ.
/// [IntrinsicHeight] + a stretched [Row] sizes every ticket to the tallest one,
/// keeping the row visually uniform. Voucher counts are small, so the extra
/// intrinsic pass is cheap.
class VoucherTicketsList extends StatelessWidget {
  const VoucherTicketsList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;

  /// Builds the ticket at [index]. [darkHead] alternates down the row (odd
  /// indices get the dark head), matching the design.
  final Widget Function(BuildContext context, int index, bool darkHead)
  itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) return const SizedBox.shrink();

    // Pin the row to the leading edge so a short list (e.g. a single ticket)
    // sits at the start of the strip rather than being centred by the parent.
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int index = 0; index < itemCount; index++) ...[
                if (index > 0) const SizedBox(width: 16),
                itemBuilder(context, index, index.isOdd),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
