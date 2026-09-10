import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/wallet/data/datasources/local/database/my_cards_database_service.dart';
import 'package:nowdelivery_user_app/features/wallet/data/datasources/remote/api/wallet_api_service.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_transaction_model.dart';

/// All data operations of the wallet feature.
///
/// Every method returns `Either<Failure, T>`: `Left` carries a user-facing
/// error message (a [LangKeys] key or a clean server message — callers apply
/// `.tr()` which leaves non-key strings untouched), `Right` carries the data.
/// The connection check and error mapping live in [_guard].
class WalletRepo {
  final WalletApiService _walletApiService = WalletApiService();
  final MyCardsDatabaseService _myCardsDatabaseService =
      MyCardsDatabaseService();

  /// The key inside the transactions `data` payload that carries the list.
  static const String _transactionsListKey = 'transactions';

  /// The key inside the cards `data` payload that carries the list.
  static const String _cardsListKey = 'cards';

  /// The key inside the set-default `data` payload that carries the card.
  static const String _defaultCardKey = 'card';

  /// Cancels every in-flight request of this repo. The actual cancellation
  /// mechanism (CancelToken) lives entirely inside the data source layer.
  void cancelRequests() => _walletApiService.cancelRequests();

  Future<Either<Failure, WalletModel>> getWalletInfo() {
    return _guard(
      () => _walletApiService.getWalletInfo(),
      (data) => WalletModel.fromJson(data),
    );
  }

  /// The customer's saved cards, server-first with a local (Hive) fallback.
  ///
  /// The whole list comes back in one un-paginated shot, so it is exposed as a
  /// plain `List` rather than a [PaginationModel]. The server is always tried
  /// first: a successful fetch refreshes the cache so the local copy tracks the
  /// server, and when the server is unreachable the last cached copy is served
  /// instead — the original failure only surfaces when nothing has been cached
  /// yet (or the cached copy can't be read).
  Future<Either<Failure, List<CardPaymentModel>>> getMyCards() async {
    // Fetch the raw server `data` object so it can be both cached verbatim and
    // parsed — the cache round-trips through the same parsing the server uses.
    final Either<Failure, Map<String, dynamic>> serverResult = await _guard(
      () => _walletApiService.getMyCards(),
      (Map<String, dynamic> data) => data,
    );

    return serverResult.fold(
      (Failure serverFailure) => _readCardsFromCache(serverFailure),
      (Map<String, dynamic> data) async {
        await _cacheMyCards(data);
        return Right<Failure, List<CardPaymentModel>>(_parseCards(data));
      },
    );
  }

  /// Parses the raw cards `data` object into the card list.
  List<CardPaymentModel> _parseCards(Map<String, dynamic> data) {
    final List<dynamic> rawItems =
        data[_cardsListKey] as List<dynamic>? ?? <dynamic>[];
    return rawItems
        .map((dynamic e) => CardPaymentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Persists the raw cards [data] payload verbatim. Best-effort: a cache write
  /// failure is a side effect, not part of the result, so it is swallowed.
  Future<void> _cacheMyCards(Map<String, dynamic> data) async {
    try {
      await _myCardsDatabaseService.saveMyCards(jsonEncode(data));
    } catch (_) {
      // Intentionally ignored — caching must never break a successful fetch.
    }
  }

  /// Falls back to the cached cards, surfacing [serverFailure] only when there
  /// is nothing cached (or the cached copy can't be read).
  Future<Either<Failure, List<CardPaymentModel>>> _readCardsFromCache(
    Failure serverFailure,
  ) async {
    try {
      final String? cached = _myCardsDatabaseService.getMyCards();
      if (cached == null) {
        return Left<Failure, List<CardPaymentModel>>(serverFailure);
      }

      final Map<String, dynamic> data =
          jsonDecode(cached) as Map<String, dynamic>;
      return Right<Failure, List<CardPaymentModel>>(_parseCards(data));
    } catch (_) {
      return Left<Failure, List<CardPaymentModel>>(serverFailure);
    }
  }

  Future<Either<Failure, PaginationModel<WalletTransactionModel>>>
      getWalletTransactions({required int page}) {
    return _guard(
      () => _walletApiService.getWalletTransactions(page: page),
      (data) => _paginated(
        data,
        _transactionsListKey,
        WalletTransactionModel.fromJson,
      ),
    );
  }

  /// Tops the wallet up with [amount] via [paymentMethodId]. The response
  /// carries only a success flag and message (no data payload), so `Right`
  /// holds nothing — callers only need success vs. failure. [idempotencyKey]
  /// lets the server dedupe retries of the same top-up.
  Future<Either<Failure, void>> topUpWallet({
    required int amount,
    required int paymentMethodId,
    required String idempotencyKey,
  }) {
    return _action(
      () => _walletApiService.topUpWallet(
        amount: amount,
        paymentMethodId: paymentMethodId,
        idempotencyKey: idempotencyKey,
      ),
    );
  }

  /// Deletes the saved card [id]. Success-only response (no data payload).
  Future<Either<Failure, void>> deletePaymentCard(int id) {
    return _action(() => _walletApiService.deletePaymentCard(id));
  }

  /// Marks the saved card [id] as the default and returns the server's
  /// authoritative copy of that card, parsed from the `card` object inside the
  /// response `data`.
  Future<Either<Failure, CardPaymentModel>> setPaymentCardDefault(int id) {
    return _guard(
      () => _walletApiService.setPaymentCardDefault(id),
      (Map<String, dynamic> data) =>
          CardPaymentModel.fromJson(data[_defaultCardKey] as Map<String, dynamic>),
    );
  }

  /// Turns a `{meta, <listKey>: [...]}` payload into a [PaginationModel].
  ///
  /// `meta` is optional: endpoints that return the full list in one shot omit
  /// it, and [PaginationModel.fromJson] then derives a single-page envelope from
  /// the items alone.
  PaginationModel<T> _paginated<T>(
    Map<String, dynamic> data,
    String listKey,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final Map<String, dynamic> meta =
        data['meta'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final List<dynamic> rawItems =
        data[listKey] as List<dynamic>? ?? <dynamic>[];
    final List<T> items = rawItems
        .map((dynamic e) => fromJson(e as Map<String, dynamic>))
        .toList();
    return PaginationModel<T>.fromJson(meta, items);
  }

  /// Shared envelope for success-only actions (delete, set-default, top-up):
  /// connection check, `success` flag handling, and Dio/exception mapping.
  /// `Right` holds nothing — callers only need success vs. failure.
  Future<Either<Failure, void>> _action(
    Future<Response> Function() request,
  ) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await request();
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (body['success'] as bool? ?? false) {
        return const Right(null);
      }

      return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody =
          data is Map<String, dynamic> ? data : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (_) {
      return const Left(Failure(LangKeys.serverConnectionFailedKey));
    }
  }

  /// Shared request envelope: connection check, non-200 handling, and
  /// Dio/exception mapping, so each method only describes its own [parse].
  Future<Either<Failure, T>> _guard<T>(
    Future<Response> Function() request,
    T Function(Map<String, dynamic> data) parse,
  ) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await request();
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      return Right(parse(body['data'] as Map<String, dynamic>));
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody =
          data is Map<String, dynamic> ? data : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (_) {
      return const Left(Failure(LangKeys.serverConnectionFailedKey));
    }
  }
}
