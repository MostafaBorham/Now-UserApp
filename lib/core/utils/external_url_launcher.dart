import 'package:url_launcher/url_launcher.dart';

/// Hands [url] to the device's default external handler (browser / viewer), so
/// the OS downloads the file itself when [url] is a direct download link.
///
/// Returns `false` when the url is empty, unparseable, or no handler could be
/// launched.
Future<bool> launchExternalUrl(String? url) async {
  final String raw = url?.trim() ?? '';
  if (raw.isEmpty) {
    return false;
  }

  final Uri? uri = Uri.tryParse(raw);
  if (uri == null) {
    return false;
  }

  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
