import 'package:url_launcher/url_launcher.dart';

/// Opens the phone's dialer with [phoneNumber] pre-filled, ready to call.
///
/// Uses the `tel:` scheme, which resolves to the system `ACTION_DIAL`
/// behaviour: when more than one calling app is installed the OS shows its own
/// app-chooser bottom sheet, hands the number to the app the user picks, and
/// stops short of dialing — the user taps the call button themselves. No call
/// permission is required.
///
/// Returns `false` when the number is empty or no dialer could be launched.
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
