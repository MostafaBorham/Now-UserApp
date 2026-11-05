import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/viewmodel/get_pdf_file_vm.dart';

/// Shows the PDF at [url] inside the app, under [title]: support-chat
/// attachments, and the parked order invoice.
///
/// The URL is an authenticated API route, so the file is downloaded through
/// the shared Dio ([getPdfFileProvider]) and rendered from disk — a PDF widget
/// fetching the URL itself would go without the session token's refresh.
class PdfViewerScreen extends ConsumerWidget {
  const PdfViewerScreen({super.key, required this.url, required this.title});

  final String url;
  final String title;

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
          title,
          // A file name can be long.
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.style18SemiBold.copyWith(color: colors.black),
        ),
      ),
      body: ref
          .watch(getPdfFileProvider(url))
          .when(
            loading: () => Center(
              child: CircularProgressIndicator(color: colors.primary500Main),
            ),
            error: (Object error, _) => ServerConnectionErrorWidget(
              message: error.toString(),
              onRetry: ref.read(getPdfFileProvider(url).notifier).load,
            ),
            data: (String path) => PDF().fromPath(path),
          ),
    );
  }
}
