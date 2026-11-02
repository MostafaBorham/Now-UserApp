import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/utils/web_link_launcher.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';

void main() {
  test('an external offer carries the web address from its link', () {
    final HomeOfferModel offer = HomeOfferModel.fromJson(<String, dynamic>{
      'title': 'Offer',
      'image_url': 'https://cdn.example.com/offer.png',
      'link': <String, dynamic>{
        'kind': 'external',
        'url': 'https://now-delivery.com/offer',
      },
    });

    expect(offer.kind, 'external');
    expect(offer.url, 'https://now-delivery.com/offer');
  });

  test('an offer linking inside the app has no web address', () {
    final HomeOfferModel offer = HomeOfferModel.fromJson(<String, dynamic>{
      'link': <String, dynamic>{'kind': 'store', 'store': 4},
    });

    expect(offer.url, isNull);
  });

  test('only full http(s) addresses are handed to the OS', () async {
    for (final String? link in <String?>[
      null,
      '',
      'now-delivery.com',
      'javascript:alert(1)',
      'tel:123',
      'https://',
    ]) {
      expect(await launchWebLink(link), isFalse, reason: '$link');
    }
  });
}
