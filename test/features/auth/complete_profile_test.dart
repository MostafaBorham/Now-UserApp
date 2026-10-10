import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/formatters/name_formatter.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/profile_model.dart';

void main() {
  group('nameInputFormatter', () {
    String typed(String text) => nameInputFormatter
        .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: text))
        .text;

    test('keeps letters of any script, diacritics, spaces, - and \'', () {
      expect(typed("Jean-Luc O'Neil"), "Jean-Luc O'Neil");
      expect(typed('مُحَمَّد عبد الله'), 'مُحَمَّد عبد الله');
    });

    test('drops digits, symbols and emoji (BUG-011, BUG-016)', () {
      expect(typed('Basem123!@#\$%😀👍🏽'), 'Basem');
      expect(typed('ياسر٣😀'), 'ياسر');
    });
  });

  group('ProfileModel.profileCompleted gates the completion screen', () {
    test('false is the only value that sends the user to the screen', () {
      expect(
        ProfileModel.fromJson(<String, dynamic>{
          'profile_completed': false,
        }).profileCompleted,
        isFalse,
      );
    });

    test('true does not', () {
      expect(
        ProfileModel.fromJson(<String, dynamic>{
          'profile_completed': true,
        }).profileCompleted,
        isTrue,
      );
    });

    test('an absent flag reads as null, which never traps the user', () {
      // The gates compare against `false`, so a payload without the field —
      // an older backend, or the cached copy of one — leaves the user alone.
      final ProfileModel profile = ProfileModel.fromJson(<String, dynamic>{
        'full_name': 'ياسر',
      });
      expect(profile.profileCompleted, isNull);
      expect(profile.profileCompleted == false, isFalse);
    });

    test('is never sent back to the server', () {
      final ProfileModel edited = ProfileModel.fromJson(<String, dynamic>{
        'full_name': 'ياسر',
        'profile_completed': false,
      });
      expect(edited.changesFrom(null), isNot(contains('profile_completed')));
    });
  });
}
