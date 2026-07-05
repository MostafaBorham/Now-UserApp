import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';

import 'add_new_card_form.dart';
import 'section_title.dart';

/// "Add New Card" section — the header plus the card entry form.
class AddNewCardSection extends StatelessWidget {
  const AddNewCardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(LangKeys.addNewCardKey.tr()),
        const SizedBox(height: 14),
        const AddNewCardForm(),
      ],
    );
  }
}
