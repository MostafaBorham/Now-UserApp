import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// Renders the order invoice PDF straight from its [invoiceUrl] inside the app.
/// The viewer fetches and displays the file itself; nothing else in the app
/// touches the network for it.
class InvoiceViewerScreen extends StatelessWidget {
  const InvoiceViewerScreen({super.key, required this.invoiceUrl});

  final String invoiceUrl;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Scaffold(
      backgroundColor: colors.neutral400,
      appBar: AppBar(
        backgroundColor: colors.white,
        foregroundColor: colors.black,
        centerTitle: true,
        title: Text(
          LangKeys.printInvoiceKey.tr(),
          style: AppTextStyles.style18SemiBold.copyWith(color: colors.black),
        ),
      ),
      body: PDF().cachedFromUrl(
        invoiceUrl,
        placeholder: (double progress) => Center(
          child: CircularProgressIndicator(color: colors.primary500Main),
        ),
        errorWidget: (dynamic error) => Center(
          child: Text(
            LangKeys.invoiceDownloadFailedKey.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.style14Regular.copyWith(
              color: colors.neutral500,
            ),
          ),
        ),
      ),
    );
  }
}
