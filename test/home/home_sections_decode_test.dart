import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';
import 'package:nowdelivery_user_app/features/home/data/repo/home_sections_repo.dart';

/// The feed is now cached as the raw response body — envelope and all — while
/// installs from before that still hold the bare `data` object. Both must read
/// back as the same sections.
void main() {
  final Map<String, dynamic> data = <String, dynamic>{
    'sections': <Map<String, dynamic>>[
      {
        'id': 677,
        'type': 'featured_offers',
        'items': <Map<String, dynamic>>[
          {
            'title': 'A',
            'image_url': 'http://x/a.jpg',
            'link': {'kind': 'store', 'store': 7},
          },
        ],
      },
      {'id': 678, 'type': 'all_stores', 'items': <Object>[]},
    ],
  };

  List<HomeSectionModel> decode(Object json) =>
      decodeHomeSections(jsonDecode(jsonEncode(json)));

  test('reads the raw response envelope', () {
    final List<HomeSectionModel> sections = decode(<String, dynamic>{
      'success': true,
      'data': data,
    });

    expect(sections.map((HomeSectionModel s) => s.id), <int>[677, 678]);
    expect(sections.first.offers.single.storeId, 7);
  });

  test('reads the bare data object cached by older installs', () {
    expect(
      decode(data),
      decode(<String, dynamic>{'success': true, 'data': data}),
    );
  });

  test('a body without sections is an empty feed, not an error', () {
    expect(decode(<String, dynamic>{'success': true}), isEmpty);
    expect(decode(<Object>[]), isEmpty);
  });
}
