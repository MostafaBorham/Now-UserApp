import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/common/route/app_routes.dart';
import 'package:nowdelivery_user_app/common/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/common/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/common/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/categories/category_card.dart';
import 'package:nowdelivery_user_app/common/presentation/widgets/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/common/presentation/widgets/reverse_widget.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const List<CategoryModel> _sampleCategories = [
    CategoryModel(
      id: 1,
      name: 'عروض',
      imageUrl:
          'https://www.figma.com/api/mcp/asset/7d9f04b2-0431-4948-8bff-4e9caa44056e',
      discountPercentage: 50,
    ),
    CategoryModel(
      id: 2,
      name: 'تخفيضات تصفية',
      imageUrl:
          'https://www.figma.com/api/mcp/asset/06393496-7500-41a1-956c-99a16ddbf2b6',
    ),
    CategoryModel(
      id: 3,
      name: 'الجمال',
      imageUrl:
          'https://www.figma.com/api/mcp/asset/6464b7a9-0107-4307-9116-588b71dc1066',
    ),
    CategoryModel(
      id: 4,
      name: 'الموضة',
      imageUrl:
          'https://www.figma.com/api/mcp/asset/99ba1424-4aed-4ddd-918c-f044340c5ef9',
    ),
    CategoryModel(
      id: 5,
      name: 'الخضروات',
      imageUrl:
          'https://www.figma.com/api/mcp/asset/e962273a-644d-46ad-9a65-912615814464',
    ),
    CategoryModel(
      id: 6,
      name: 'الوجبات السريعة والمشروبات',
      imageUrl:
          'https://www.figma.com/api/mcp/asset/1d30eb01-53fb-49e6-a4a4-f77525134d66',
    ),
    CategoryModel(
      id: 7,
      name: 'يمكن ارتداؤها',
      imageUrl:
          'https://www.figma.com/api/mcp/asset/315c4171-622b-41cc-9f1e-428755f26fc6',
    ),
    CategoryModel(
      id: 8,
      name: 'الأجهزة الإلكترونية',
      imageUrl:
          'https://www.figma.com/api/mcp/asset/a6088c35-e7d1-4481-8f1d-5aedecb8b4e6',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: AppWavedScaffold(
        body: GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 20,
            mainAxisExtent: 220,
          ),
          itemCount: _sampleCategories.length,
          itemBuilder: (BuildContext context, int index) => CategoryCard(
            category: _sampleCategories.elementAt(index),
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.categoryDetailsScreen),
          ),
        ),
        appBarTitle: LangKeys.categoriesTitleKey.tr(),
        canPop: Navigator.canPop(context),
      ),
    );
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 70),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.onSecondaryFixed,
              colors.onPrimary,
              colors.onPrimary,
            ],
          ),
        ),
        child: Column(
          spacing: 20,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: CircleAvatar(
                      backgroundColor: colors.onPrimary,
                      radius: 20.r,
                      child: ReverseWidget(
                        child: Assets.media.images.svg.arrowBrokenIcon.svg(),
                      ),
                    ),
                  ),
                  AutoSizeText(
                    LangKeys.categoriesTitleKey.tr(),
                    style: AppTextStyles.style24SemiBold.copyWith(
                      color: colors.onSecondary,
                    ),
                  ),
                  20.wSpace,
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Assets.media.images.svg.whiteWaveBackground.svg(
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 50.0,
                    ).copyWith(bottom: 0),
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 20,
                        mainAxisExtent: 220,
                      ),
                      itemCount: _sampleCategories.length,
                      itemBuilder: (BuildContext context, int index) =>
                          CategoryCard(
                            category: _sampleCategories.elementAt(index),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
