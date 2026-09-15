import 'package:url_launcher/url_launcher.dart';










Future<bool> launchPhoneDialer(String? phoneNumber) async {
  final String number = phoneNumber?.trim() ?? '';
  if (number.isEmpty) {
    return false;
  }

  final Uri uri = Uri(scheme: 'tel', path: number);
  if (!await canLaunchUrl(uri)) {
    return false;
  }

  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
