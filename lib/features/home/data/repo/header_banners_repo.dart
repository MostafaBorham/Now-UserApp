import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/home/data/datasources/local/database/header_banners_database_service.dart';
import 'package:nowdelivery_user_app/features/home/data/datasources/remote/api/header_banners_api_service.dart';

/// Data operations for the home header banners. Returns `Either<Failure, T>`:
/// `Left` carries a user-facing message (a [LangKeys] key or a raw server
/// message — callers apply `.tr()`, which leaves non-key strings untouched).
class HeaderBannersRepo {
  final HeaderBannersApiService _apiService = HeaderBannersApiService();
  final HeaderBannersDatabaseService _databaseService =
      HeaderBannersDatabaseService();

  void cancelRequests() => _apiService.cancelRequests();

  /// The published `header_main_page` banners, server-first with a local (Hive)
  /// fallback. A successful fetch refreshes the cache; when the server is
  /// unreachable the last-seen banners are served from the cache instead. A
  /// missing or corrupt cache surfaces the server failure (an empty list is
  /// valid — the admin has published no header banners yet).
  Future<Either<Failure, List<BannerModel>>> getHeaderBanners() async {
    // Fetch the raw server `data` object so it can be both cached verbatim and
    // parsed — the cache round-trips through the same parsing the server uses.
    final Either<Failure, Map<String, dynamic>> serverResult =
        await _fetchFromServer();

    return serverResult.fold(
      // Server failed (offline or error) → fall back to the cached banners.
      (Failure serverFailure) => _readFromCache(serverFailure),
      // Server succeeded → refresh the cache, then parse.
      (Map<String, dynamic> data) async {
        await _cacheHeaderBanners(data);
        return Right<Failure, List<BannerModel>>(_parseBanners(data));
      },
    );
  }

  /// Runs the guarded server request and returns the raw server `data` object.
  Future<Either<Failure, Map<String, dynamic>>> _fetchFromServer() async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _apiService.getHeaderBanners();

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      return Right(body['data'] as Map<String, dynamic>);
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody =
          data is Map<String, dynamic> ? data : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (exception) {
      return Left(Failure(exception.toString()));
    }
  }

  /// Persists the raw banners [data] payload. Best-effort: a cache write failure
  /// is a side effect, not part of the result, so it is swallowed.
  Future<void> _cacheHeaderBanners(Map<String, dynamic> data) async {
    try {
      await _databaseService.saveHeaderBanners(jsonEncode(data));
    } catch (_) {
      // Intentionally ignored — caching must never break a successful fetch.
    }
  }

  /// Serves the cached banners when the server is unreachable. A missing or
  /// corrupt cache surfaces the original [serverFailure].
  Future<Either<Failure, List<BannerModel>>> _readFromCache(
    Failure serverFailure,
  ) async {
    try {
      final String? cached = _databaseService.getHeaderBanners();
      if (cached == null) {
        return Left<Failure, List<BannerModel>>(serverFailure);
      }

      final Map<String, dynamic> data =
          jsonDecode(cached) as Map<String, dynamic>;
      return Right<Failure, List<BannerModel>>(_parseBanners(data));
    } catch (_) {
      return Left<Failure, List<BannerModel>>(serverFailure);
    }
  }

  /// Parses the raw server `data` object into the banners list — the same
  /// mapping for a live response and a cached one.
  List<BannerModel> _parseBanners(Map<String, dynamic> data) {
    final List<dynamic> rawBanners =
        data['banners'] as List<dynamic>? ?? <dynamic>[];
    return rawBanners
        .whereType<Map<String, dynamic>>()
        .map(BannerModel.fromJson)
        .toList();
  }
}
