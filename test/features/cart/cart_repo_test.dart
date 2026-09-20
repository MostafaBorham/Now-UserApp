import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/cart/data/datasources/remote/api/cart_api_service.dart';
import 'package:nowdelivery_user_app/features/cart/data/datasources/remote/api/cart_endpoints.dart';
import 'package:nowdelivery_user_app/features/cart/data/models/cart_model.dart';
import 'package:nowdelivery_user_app/features/cart/data/repo/cart_repo.dart';

/// Pins the failure contract of [CartRepo].
///
/// The cart screen renders `Failure.message` as its whole error state, so
/// anything that escapes the repo is what the shopper reads instead of their
/// basket. This file exists because two things used to escape: a `data` that
/// was not an object (an empty cart serialises as `[]`) threw out of the cast,
/// and the catch-all handed `e.toString()` straight through — so a Dart type
/// error became the cart screen's message.
void main() {
  Map<String, dynamic> envelope(dynamic data) => <String, dynamic>{
    'success': true,
    'data': data,
  };

  Map<String, dynamic> cartPayload = <String, dynamic>{
    'cart': <String, dynamic>{
      'id': 1,
      'vendors': <dynamic>[
        <String, dynamic>{
          'vendor': <String, dynamic>{'id': 3, 'name': 'Panda'},
          'products': <dynamic>[
            <String, dynamic>{'product_id': 7, 'quantity': 2},
          ],
          'pricing': <String, dynamic>{'min_order_value': 50, 'total': 80},
        },
      ],
    },
  };

  Response<dynamic> answer(int statusCode, dynamic data) => Response<dynamic>(
    requestOptions: RequestOptions(path: '/api/v1/cart'),
    statusCode: statusCode,
    data: data,
  );

  _FakeCartApi replying(int statusCode, dynamic data) =>
      _FakeCartApi(response: answer(statusCode, data));

  /// The request never got an answer — timeout, DNS, dropped connection,
  /// cancellation. `DioException.response` is null for all of them.
  _FakeCartApi unreachable() => _FakeCartApi(
    error: DioException(
      requestOptions: RequestOptions(path: '/api/v1/cart'),
      type: DioExceptionType.connectionTimeout,
    ),
  );

  CartRepo repoOn(_FakeCartApi api, {bool connected = true}) =>
      CartRepo(api: api, isConnected: () async => connected);

  String failureMessage(Either<Failure, Object?> result) =>
      result.fold((Failure failure) => failure.message, (Object? right) {
        fail('expected a Left, got Right($right)');
      });

  CartModel cartOf(Either<Failure, CartModel> result) => result.fold(
    (Failure failure) => fail('expected a Right, got Left(${failure.message})'),
    (CartModel cart) => cart,
  );

  group('parsing', () {
    test('reads the cart out of the envelope', () async {
      final CartModel cart = cartOf(
        await repoOn(replying(200, envelope(cartPayload))).getCart(),
      );

      expect(cart.id, 1);
      expect(cart.quantityOf(7), 2);
      expect(cart.vendors.single.pricing.minOrderValue, 50.0);
    });

    test('treats an empty cart sent as `data: []` as an empty cart', () async {
      final CartModel cart = cartOf(
        await repoOn(replying(200, envelope(<dynamic>[]))).getCart(),
      );

      expect(cart.vendors, isEmpty);
    });

    test('treats a missing or null `data` as an empty cart', () async {
      expect(
        cartOf(await repoOn(replying(200, envelope(null))).getCart()).vendors,
        isEmpty,
      );
      expect(
        cartOf(
          await repoOn(
            replying(200, <String, dynamic>{'success': true}),
          ).getCart(),
        ).vendors,
        isEmpty,
      );
    });

    test('accepts a 201 from add-to-cart', () async {
      final CartModel cart = cartOf(
        await repoOn(
          replying(201, envelope(cartPayload)),
        ).addToCart(7, 1, null),
      );

      expect(cart.quantityOf(7), 2);
    });

    test('forwards cart_item_id to the api service', () async {
      final _FakeCartApi api = replying(200, envelope(cartPayload));

      await repoOn(api).updateCartProductQuantity(7, 3, cartItemId: 64);

      expect(api.lastCartItemId, 64);
      expect(CartEndpoints.cartItemQuery(64), <String, dynamic>{
        'cart_item_id': 64,
      });
      expect(CartEndpoints.cartItemQuery(null), isEmpty);
    });
  });

  group('failures', () {
    test('offline short-circuits before the request', () async {
      final _FakeCartApi api = replying(200, envelope(cartPayload));

      final Either<Failure, CartModel> result = await repoOn(
        api,
        connected: false,
      ).getCart();

      expect(failureMessage(result), LangKeys.noInternetConnectionKey);
      expect(api.calls, 0);
    });

    test('a 2xx with success:false is a failure, not an empty cart', () async {
      final Either<Failure, CartModel> result = await repoOn(
        replying(200, <String, dynamic>{
          'success': false,
          'message': 'Product is out of stock',
        }),
      ).updateCartProductQuantity(7, 3);

      expect(failureMessage(result), 'Product is out of stock');
    });

    test('carries the server message from a rejected request', () async {
      final Either<Failure, CartModel> result = await repoOn(
        _FakeCartApi(
          error: DioException(
            requestOptions: RequestOptions(path: '/api/v1/cart'),
            response: answer(422, <String, dynamic>{
              'success': false,
              'message': 'Quantity exceeds available stock',
            }),
          ),
        ),
      ).updateCartProductQuantity(7, 99);

      expect(failureMessage(result), 'Quantity exceeds available stock');
    });

    test(
      'an unreachable server gets a translatable key, not English',
      () async {
        final Either<Failure, CartModel> result = await repoOn(
          unreachable(),
        ).getCart();

        expect(failureMessage(result), LangKeys.serverConnectionFailedKey);
      },
    );

    test('never surfaces a raw Dart error as the message', () async {
      // A body shaped nothing like the envelope: whatever goes wrong reading
      // it, the shopper must not be shown the exception text.
      final Either<Failure, CartModel> result = await repoOn(
        replying(200, 'a plain string body'),
      ).getCart();

      final String message = failureMessage(result);
      expect(message, isNot(contains('is not a subtype of')));
      expect(message, isNot(contains('Exception')));
    });
  });
}

class _FakeCartApi implements CartApiService {
  _FakeCartApi({this.response, this.error});

  final Response<dynamic>? response;
  final Object? error;
  int calls = 0;

  Future<Response> _answer() async {
    calls++;
    if (error != null) throw error!;
    return response!;
  }

  @override
  void cancelRequests() {}

  @override
  Future<Response> getCart() => _answer();

  @override
  Future<Response> deleteCartVendorItem(int vendorId) => _answer();

  int? lastCartItemId;

  @override
  Future<Response> updateCartProductQuantity(
    int productId,
    int quantity, {
    int? cartItemId,
  }) {
    lastCartItemId = cartItemId;
    return _answer();
  }

  @override
  Future<Response> addToCart(
    int productId,
    int quantity,
    Map<String, dynamic>? options,
  ) => _answer();
}
