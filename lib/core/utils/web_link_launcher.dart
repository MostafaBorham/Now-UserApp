import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens an http(s) [link] outside the app, in the user's browser.
///
/// Anything that is not a full http or https address is ignored, so a bad
/// value from the server never hands another scheme to the OS. `launchUrl` is
/// called without `canLaunchUrl` first: that check needs a `<queries>` entry
/// on Android 11+, while launching a web address does not.
///
/// Returns `false` when the link is unusable or nothing could open it.
Future<bool> launchWebLink(String? link) async {
  final Uri? uri = Uri.tryParse(link?.trim() ?? '');
  if (uri == null ||
      !(uri.scheme == 'https' || uri.scheme == 'http') ||
      uri.host.isEmpty) {
    return false;
  }

  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (error) {
    debugPrint('launchWebLink failed for $uri: $error');
    return false;
  }
}
