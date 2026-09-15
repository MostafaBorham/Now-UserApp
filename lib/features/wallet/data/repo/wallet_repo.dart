import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/wallet/data/datasources/local/database/my_cards_database_service.dart';
import 'package:nowdelivery_user_app/features/wallet/data/datasources/local/database/wallet_info_database_service.dart';
import 'package:nowdelivery_user_app/features/wallet/data/datasources/remote/api/wallet_api_service.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/card_payment_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_model.dart';
import 'package:nowdelivery_user_app/features/wallet/data/models/wallet_transaction_model.dart';







class WalletRepo {
  final WalletApiService _walletApiService = WalletApiService();
  final MyCardsDatabaseService _myCardsDatabaseService =
      MyCardsDatabaseService();
  final WalletInfoDatabaseService _walletInfoDatabaseService =
      WalletInfoDatabaseService();


  static const String _transactionsListKey = 'transactions';


  static const String _cardsListKey = 'cards';


  static const String _defaultCardKey = 'card';



  void cancelRequests() => _walletApiService.cancelRequests();







  Future<Either<Failure, WalletModel>> getWalletInfo() async {


    final Either<Failure, Map<String, dynamic>> serverResult = await _guard(
      () => _walletApiService.getWalletInfo(),
      (Map<String, dynamic> data) => data,
    );

    return serverResult.fold(
      (Failure serverFailure) => _readWalletInfoFromCache(serverFailure),
      (Map<String, dynamic> data) async {
        await _cacheWalletInfo(data);
        return Right<Failure, WalletModel>(WalletModel.fromJson(data));
      },
    );
  }



  Future<void> _cacheWalletInfo(Map<String, dynamic> data) async {
    try {
      await _walletInfoDatabaseService.saveWalletInfo(jsonEncode(data));
    } catch (_) {

    }
  }



  Future<Either<Failure, WalletModel>> _readWalletInfoFromCache(
    Failure serverFailure,
  ) async {
    try {
      final String? cached = _walletInfoDatabaseService.getWalletInfo();
      if (cached == null) {
        return Left<Failure, WalletModel>(serverFailure);
      }

      final Map<String, dynamic> data =
          jsonDecode(cached) as Map<String, dynamic>;
      return Right<Failure, WalletModel>(WalletModel.fromJson(data));
    } catch (_) {
      return Left<Failure, WalletModel>(serverFailure);
    }
  }









  Future<Either<Failure, List<CardPaymentModel>>> getMyCards() async {


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


  List<CardPaymentModel> _parseCards(Map<String, dynamic> data) {
    final List<dynamic> rawItems =
        data[_cardsListKey] as List<dynamic>? ?? <dynamic>[];
    return rawItems
        .map((dynamic e) => CardPaymentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }



  Future<void> _cacheMyCards(Map<String, dynamic> data) async {
    try {
      await _myCardsDatabaseService.saveMyCards(jsonEncode(data));
    } catch (_) {

    }
  }



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









  Future<Either<Failure, WalletModel>> topUpWallet({
    required int amount,
    required int paymentMethodId,
    required String idempotencyKey,
  }) async {


    final Either<Failure, Map<String, dynamic>> serverResult = await _guard(
      () => _walletApiService.topUpWallet(
        amount: amount,
        paymentMethodId: paymentMethodId,
        idempotencyKey: idempotencyKey,
      ),
      (Map<String, dynamic> data) => data,
    );

    return serverResult.fold(
      (Failure serverFailure) => Left<Failure, WalletModel>(serverFailure),
      (Map<String, dynamic> data) async {
        await _cacheWalletInfo(data);
        return Right<Failure, WalletModel>(WalletModel.fromJson(data));
      },
    );
  }


  Future<Either<Failure, void>> deletePaymentCard(int id) {
    return _action(() => _walletApiService.deletePaymentCard(id));
  }




  Future<Either<Failure, CardPaymentModel>> setPaymentCardDefault(int id) {
    return _guard(
      () => _walletApiService.setPaymentCardDefault(id),
      (Map<String, dynamic> data) =>
          CardPaymentModel.fromJson(data[_defaultCardKey] as Map<String, dynamic>),
    );
  }






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
