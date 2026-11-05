import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_invoice_pdf_vm.dart';

/// Shows the order invoice PDF at [invoiceUrl] inside the app.
///
/// The URL is an authenticated API route, so the file is downloaded through
/// the shared Dio ([getInvoicePdfProvider]) and rendered from disk — a PDF
/// widget fetching the URL itself would go without the session token.
class InvoiceViewerScreen extends ConsumerWidget {
  const InvoiceViewerScreen({super.key, required this.invoiceUrl});

  final String invoiceUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      body: ref
          .watch(getInvoicePdfProvider(invoiceUrl))
          .when(
            loading: () => Center(
              child: CircularProgressIndicator(color: colors.primary500Main),
            ),
            error: (Object error, _) => ServerConnectionErrorWidget(
              message: error.toString(),
              onRetry: ref
                  .read(getInvoicePdfProvider(invoiceUrl).notifier)
                  .load,
            ),
            data: (String path) => PDF().fromPath(path),
          ),
    );
  }
}
