import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// "Closed" or "Busy" pill for a store; nothing for an open one.
class StoreStatusBadge extends StatelessWidget {
  const StoreStatusBadge({super.key, required this.store});

  final StoreModel store;

  @override
  Widget build(BuildContext context) {
    if (!store.isClosed && !store.isBusy) return const SizedBox.shrink();

    final AppColorScheme colors = context.colors;
    final bool closed = store.isClosed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: closed ? colors.red300Main : colors.orange100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        (closed ? LangKeys.storeClosedKey : LangKeys.storeBusyKey).tr(),
        style: AppTextStyles.style12SemiBold.copyWith(
          color: closed ? colors.white : colors.orange900,
        ),
      ),
    );
  }
}
