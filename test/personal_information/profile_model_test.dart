import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/utils/app_validator.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/profile_model.dart';

void main() {
  const ProfileModel loaded = ProfileModel(
    id: 7,
    fullName: 'Basem',
    email: 'basem@example.com',
    phone: '+966512345678',
    gender: 'male',
    birthday: '1995-04-17',
  );

  ProfileModel edit({
    Object? fullName = _unset,
    Object? email = _unset,
    Object? gender = _unset,
    Object? birthday = _unset,
  }) {
    return ProfileModel(
      fullName: fullName == _unset ? loaded.fullName : fullName as String?,
      email: email == _unset ? loaded.email : email as String?,
      gender: gender == _unset ? loaded.gender : gender as String?,
      birthday: birthday == _unset ? loaded.birthday : birthday as String?,
    );
  }

  group('ProfileModel.changesFrom', () {
    test('an untouched form sends nothing', () {
      expect(edit().changesFrom(loaded), isEmpty);
    });

    test('only the edited key is sent', () {
      expect(
        edit(fullName: 'Basem Elsawah').changesFrom(loaded),
        <String, dynamic>{'full_name': 'Basem Elsawah'},
      );
    });

    test('an emptied field is sent as an explicit null to clear it', () {
      expect(edit(email: null).changesFrom(loaded), <String, dynamic>{
        'email': null,
      });
    });

    test('phone is never sent — it is the OTP identity', () {
      final Map<String, dynamic> body = edit(
        fullName: 'Someone Else',
        email: null,
        gender: 'female',
        birthday: '2000-01-01',
      ).changesFrom(loaded);

      expect(body.keys, isNot(contains('phone')));
      expect(body.keys, hasLength(4));
    });

    test('a gender the toggle cannot represent survives an unrelated edit', () {
      const ProfileModel other = ProfileModel(
        fullName: 'Basem',
        gender: 'other',
      );
      final Map<String, dynamic> body = const ProfileModel(
        fullName: 'Basem Elsawah',
        gender: 'other',
      ).changesFrom(other);

      expect(body, <String, dynamic>{'full_name': 'Basem Elsawah'});
      expect(body.keys, isNot(contains('gender')));
    });

    test('a blank form with no baseline sends nothing', () {
      expect(const ProfileModel().changesFrom(null), isEmpty);
    });

    test('with no baseline, only what the user actually typed is sent', () {
      expect(
        const ProfileModel(fullName: 'Basem').changesFrom(null),
        <String, dynamic>{'full_name': 'Basem'},
      );
    });
  });

  group('ProfileModel.fromJson', () {
    test('prefers full_name and falls back to name', () {
      expect(
        ProfileModel.fromJson(<String, dynamic>{
          'full_name': 'A',
          'name': 'B',
        }).fullName,
        'A',
      );
      expect(
        ProfileModel.fromJson(<String, dynamic>{'name': 'B'}).fullName,
        'B',
      );
    });

    test('a null user object yields an empty profile, not a crash', () {
      expect(ProfileModel.fromJson(null), const ProfileModel());
    });

    test('coerces a numeric or string id', () {
      expect(ProfileModel.fromJson(<String, dynamic>{'id': 7}).id, 7);
      expect(ProfileModel.fromJson(<String, dynamic>{'id': '7'}).id, 7);
      expect(ProfileModel.fromJson(<String, dynamic>{}).id, isNull);
    });
  });

  group('AppValidator.isValidEmail', () {
    test('accepts ordinary addresses', () {
      for (final String email in <String>[
        'basem@example.com',
        'basem.elsawah+tag@now-delivery.com',
        'a@b.co.uk',
        'a+b@x.co.uk',
        'first_last@mail.example.com',
        'first-last.2026@x--y.io',
        '13426.2452@gmail.com',
      ]) {
        expect(AppValidator.isValidEmail(email), isTrue, reason: email);
      }
    });

    test('rejects the obvious typos', () {
      for (final String email in <String>[
        'asdf',
        'basem@',
        '@example.com',
        'basem@example',
        'basem @example.com',
        // A domain without a real TLD (BUG-010).
        'a@b',
        '1@2.3',
        '13426.2452@1245677',
        // Punctuation where a letter or digit has to be (BUG-012).
        '-------.------@-------',
        '-------.------@-------.com',
        '_basem@example.com',
        'basem_@example.com',
        '.basem@example.com',
        'basem.@example.com',
        'ba..sem@example.com',
        'ba._sem@example.com',
        'basem@-example.com',
        'basem@example-.com',
        'basem@exa_mple.com',
        'basem@.example.com',
      ]) {
        expect(AppValidator.isValidEmail(email), isFalse, reason: email);
      }
    });
  });
}

const Object _unset = Object();
