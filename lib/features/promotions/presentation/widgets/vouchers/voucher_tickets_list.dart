import 'package:flutter/material.dart';










class VoucherTicketsList extends StatelessWidget {
  const VoucherTicketsList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;



  final Widget Function(BuildContext context, int index, bool darkHead)
  itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) return const SizedBox.shrink();



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
