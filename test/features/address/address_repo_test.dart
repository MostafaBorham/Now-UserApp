import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/remote/api/address_api_service.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/data/repo/address_repo.dart';

/// Pins the failure contract of [AddressRepo].
///
/// The repo answers six endpoints through six hand-copied try/catch blocks, and
/// this file exists because that duplication is about to be collapsed into one
/// envelope. The `parsing` and `already correct` groups say what must survive
/// that rewrite untouched; the `must be fixed` group says what the rewrite is
/// for — a timeout that shows untranslated English, a raw Dart cast error in a
/// snackbar, and a 201/204 the repo refuses to accept.
void main() {
  const Map<String, dynamic> addressJson = <String, dynamic>{
    'id': 12,
    'label': <String, dynamic>{'en': 'Home', 'ar': 'المنزل'},
    'full_address': 'Al Olaya, Riyadh',
    'is_default': true,
  };

  Response<dynamic> answer(int statusCode, dynamic data) {
    return Response<dynamic>(
      requestOptions: RequestOptions(path: '/addresses'),
      statusCode: statusCode,
      data: data,
    );
  }

  /// The server answered, with [data] as its body.
  _FakeAddressApi replying(int statusCode, dynamic data) =>
      _FakeAddressApi(response: answer(statusCode, data));

  /// The request never got an answer — timeout, DNS, dropped connection,
  /// cancellation. `DioException.response` is null for all of them.
  _FakeAddressApi unreachable() => _FakeAddressApi(
        error: DioException(
          requestOptions: RequestOptions(path: '/addresses'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

  AddressRepo repoOn(_FakeAddressApi api, {bool connected = true}) {
    return AddressRepo(api: api, isConnected: () async => connected);
  }

  /// The message of a `Left`, or a failing matcher if the result was a `Right`.
  String failureMessage(Either<Failure, Object?> result) {
    return result.fold((Failure failure) => failure.message, (Object? right) {
      fail('expected a Left, got Right($right)');
    });
  }

  group('parsing — must survive the rewrite', () {
    test('getMyAddresses reads the pagination envelope and the addresses', () async {
      final AddressRepo repo = repoOn(
        replying(200, <String, dynamic>{
          'data': <String, dynamic>{
            'pagination': <String, dynamic>{
              'current_page': 2,
              'last_page': 5,
              'per_page': 10,
              'total': 47,
              'has_more': true,
            },
            'addresses': <dynamic>[addressJson],
          },
        }),
      );

      final Either<Failure, PaginationModel<AddressModel>> result =
          await repo.getMyAddresses(page: 2);

      final PaginationModel<AddressModel> page = result.getOrElse(
        () => fail('expected a Right'),
      );
      expect(page.currentPage, 2);
      expect(page.lastPage, 5);
      expect(page.total, 47);
      expect(page.hasMore, isTrue);
      expect(page.data.single.id, 12);
      expect(page.data.single.fullAddress, 'Al Olaya, Riyadh');
    });

    test('getMyAddresses treats a missing addresses key as an empty page', () async {
      final AddressRepo repo = repoOn(
        replying(200, <String, dynamic>{'data': <String, dynamic>{}}),
      );

      final Either<Failure, PaginationModel<AddressModel>> result =
          await repo.getMyAddresses(page: 1);

      expect(result.getOrElse(() => fail('expected a Right')).data, isEmpty);
    });

    test('addAddress returns the address the server assigned an id', () async {
      final AddressRepo repo = repoOn(
        replying(200, <String, dynamic>{
          'data': <String, dynamic>{'address': addressJson},
        }),
      );

      final Either<Failure, AddressModel> result =
          await repo.addAddress(address: const AddressModel());

      expect(result.getOrElse(() => fail('expected a Right')).id, 12);
    });

    test('getDefaultAddress reads data.address', () async {
      final AddressRepo repo = repoOn(
        replying(200, <String, dynamic>{
          'data': <String, dynamic>{'address': addressJson},
        }),
      );

      final Either<Failure, AddressModel> result =
          await repo.getDefaultAddress();

      expect(
        result.getOrElse(() => fail('expected a Right')).isDefault,
        isTrue,
      );
    });

    test('deleteAddress succeeds without reading a body', () async {
      final AddressRepo repo = repoOn(
        replying(200, <String, dynamic>{'data': <dynamic>[]}),
      );

      final Either<Failure, Unit> result = await repo.deleteAddress(
        addressId: 12,
      );

      expect(result.isRight(), isTrue);
    });
  });

  group('already correct — must survive the rewrite', () {
    test('offline fails with the no-internet key and issues no request', () async {
      final _FakeAddressApi api = replying(200, <String, dynamic>{});
      final AddressRepo repo = repoOn(api, connected: false);

      final Either<Failure, PaginationModel<AddressModel>> result =
          await repo.getMyAddresses(page: 1);

      expect(failureMessage(result), LangKeys.noInternetConnectionKey);
      expect(api.calls, 0, reason: 'offline must not reach the network');
    });

    test("a rejected request surfaces the server's own message", () async {
      final AddressRepo repo = repoOn(
        replying(422, <String, dynamic>{'message': 'Phone number is required'}),
      );

      final Either<Failure, AddressModel> result =
          await repo.addAddress(address: const AddressModel());

      expect(failureMessage(result), 'Phone number is required');
    });

    test('a DioException carrying a body surfaces that message', () async {
      final AddressRepo repo = repoOn(
        _FakeAddressApi(
          error: DioException(
            requestOptions: RequestOptions(path: '/addresses'),
            response: answer(403, <String, dynamic>{
              'message': 'This address belongs to another user',
            }),
          ),
        ),
      );

      final Either<Failure, Unit> result = await repo.deleteAddress(
        addressId: 12,
      );

      expect(failureMessage(result), 'This address belongs to another user');
    });
  });

  group('must be fixed by the rewrite', () {
    test('an unreachable server fails with a translatable key', () async {
      final AddressRepo repo = repoOn(unreachable());

      final Either<Failure, PaginationModel<AddressModel>> result =
          await repo.getMyAddresses(page: 1);

      // Not ApiErrorHandler's untranslated English default, which an Arabic
      // user would be shown verbatim.
      expect(failureMessage(result), LangKeys.serverConnectionFailedKey);
    });

    test('setDefaultAddress accepts a 201', () async {
      final AddressRepo repo = repoOn(
        replying(201, <String, dynamic>{
          'data': <String, dynamic>{'address': addressJson},
        }),
      );

      final Either<Failure, AddressModel> result =
          await repo.setDefaultAddress(addressId: 12);

      expect(result.isRight(), isTrue);
    });

    test('deleteAddress accepts a 204 with no body at all', () async {
      final AddressRepo repo = repoOn(replying(204, null));

      final Either<Failure, Unit> result = await repo.deleteAddress(
        addressId: 12,
      );

      expect(result.isRight(), isTrue);
    });

    test('a malformed payload never leaks a Dart exception string', () async {
      // `data` present but null: the repo casts it to a non-nullable Map.
      final AddressRepo repo = repoOn(
        replying(200, <String, dynamic>{'data': null}),
      );

      final Either<Failure, AddressModel> result =
          await repo.getDefaultAddress();

      final String message = failureMessage(result);
      expect(message, isNot(contains('is not a subtype of')));
      expect(message, LangKeys.serverConnectionFailedKey);
    });
  });
}

/// Stands in for the real service, which would build the app-wide Dio singleton
/// (auth and token-refresh interceptors included) in its field initializer.
///
/// Every endpoint funnels into the same canned answer: these tests are about the
/// envelope around the call, never about which URL was hit.
class _FakeAddressApi implements AddressApiService {
  _FakeAddressApi({this.response, this.error});

  final Response<dynamic>? response;
  final Object? error;

  /// How many requests actually went out — the offline path must leave this 0.
  int calls = 0;

  Future<Response> _answer() async {
    calls++;
    if (error != null) throw error!;
    return response!;
  }

  @override
  void cancelRequests() {}

  @override
  Future<Response> getMyAddresses({required int page}) => _answer();

  @override
  Future<Response> addAddress({required AddressModel address}) => _answer();

  @override
  Future<Response> editAddress({
    required int addressId,
    required AddressModel address,
  }) =>
      _answer();

  @override
  Future<Response> getDefaultAddress() => _answer();

  @override
  Future<Response> setDefaultAddress({required int addressId}) => _answer();

  @override
  Future<Response> deleteAddress({required int addressId}) => _answer();
}
