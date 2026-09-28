import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/formatters/name_formatter.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/profile_model.dart';

void main() {
  group('joinFullName', () {
    test('joins both parts with a single space', () {
      expect(joinFullName('ياسر', 'الأحمد'), 'ياسر الأحمد');
    });

    test('a one-word name carries no trailing separator', () {
      expect(joinFullName('ياسر', ''), 'ياسر');
      expect(joinFullName('', 'الأحمد'), 'الأحمد');
    });

    test('trims each part rather than the joined result', () {
      expect(joinFullName('  ياسر  ', '  الأحمد '), 'ياسر الأحمد');
    });

    test('whitespace-only input is empty, so validation rejects it', () {
      expect(joinFullName('   ', ' '), isEmpty);
    });

    test('keeps a multi-part name in the second box intact', () {
      expect(
        joinFullName('محمد', 'عبد الله بن سالم'),
        'محمد عبد الله بن سالم',
      );
    });
  });

  group('splitFullName', () {
    test('first word is the first name, the rest is the last name', () {
      final ({String first, String last}) name = splitFullName(
        'محمد عبد الله بن سالم',
      );
      expect(name.first, 'محمد');
      expect(name.last, 'عبد الله بن سالم');
    });

    test('a one-word name leaves the last name empty', () {
      expect(splitFullName('ياسر'), (first: 'ياسر', last: ''));
    });

    test('null or blank splits into two empty parts', () {
      expect(splitFullName(null), (first: '', last: ''));
      expect(splitFullName('   '), (first: '', last: ''));
    });

    test('extra whitespace around the parts is dropped', () {
      expect(splitFullName('  Basem   Elsawah  '), (
        first: 'Basem',
        last: 'Elsawah',
      ));
    });

    test('joining a split name gives the name back', () {
      final ({String first, String last}) name = splitFullName('Basem Elsawah');
      expect(joinFullName(name.first, name.last), 'Basem Elsawah');
    });
  });

  group('ProfileModel.profileCompleted gates the completion screen', () {
    test('false is the only value that sends the user to the screen', () {
      expect(
        ProfileModel.fromJson(<String, dynamic>{'profile_completed': false})
            .profileCompleted,
        isFalse,
      );
    });

    test('true does not', () {
      expect(
        ProfileModel.fromJson(<String, dynamic>{'profile_completed': true})
            .profileCompleted,
        isTrue,
      );
    });

    test('an absent flag reads as null, which never traps the user', () {
      // The gates compare against `false`, so a payload without the field —
      // an older backend, or the cached copy of one — leaves the user alone.
      final ProfileModel profile =
          ProfileModel.fromJson(<String, dynamic>{'full_name': 'ياسر'});
      expect(profile.profileCompleted, isNull);
      expect(profile.profileCompleted == false, isFalse);
    });

    test('is never sent back to the server', () {
      final ProfileModel edited = ProfileModel.fromJson(
        <String, dynamic>{'full_name': 'ياسر', 'profile_completed': false},
      );
      expect(edited.changesFrom(null), isNot(contains('profile_completed')));
    });
  });
}
