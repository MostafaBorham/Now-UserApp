import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_search_field.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/recent_search_widget.dart';

class AddressSearchScreen extends StatefulWidget {
  const AddressSearchScreen({super.key});

  @override
  State<AddressSearchScreen> createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends State<AddressSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Puts [term] into the field so the suggestions state takes over.
  void _onRecentSelected(String term) {
    _searchController
      ..text = term
      ..selection = TextSelection.collapsed(offset: term.length);
    setState(() => _query = term);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AppWavedView(
        appBarTitle: LangKeys.addNewAddress.tr(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: <Widget>[
            AppSearchField(
              autofocus: true,
              navigateToSearchOnTap: false,
              controller: _searchController,
              onChanged: (String value) => setState(() => _query = value),
            ),
            Expanded(
              child: _query.isEmpty
                  ? SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: RecentSearchWidget(
                        keywords: [],
                        clearLabel: LangKeys.deleteKey.tr(),
                        onSelect: _onRecentSelected,
                        onRemove: (String term) {}
                        ,
                        onClear: () {},
                      ),
                    )
                  : ListView.separated(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.zero,
                      itemCount: 3,
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (BuildContext context, int index) =>
                          ListTile(
                            title: Text('Cairo'),
                            subtitle: Text('13 Goal gamal street , Almohndsin'),
                            leading: Assets.media.images.svg.searchIcon.svg(),
                            onTap: () {},
                          ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
