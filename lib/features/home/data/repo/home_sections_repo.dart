import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/home/data/datasources/local/database/home_sections_database_service.dart';
import 'package:nowdelivery_user_app/features/home/data/datasources/remote/api/home_sections_api_service.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';

/// Data operations of the home feed. Returns `Either<Failure, T>`: `Left`
/// carries a user-facing message (a [LangKeys] key or a raw server message —
/// callers apply `.tr()`, which leaves non-key strings untouched).
class HomeSectionsRepo {
  final HomeSectionsApiService _apiService = HomeSectionsApiService();
  final HomeSectionsDatabaseService _databaseService =
      HomeSectionsDatabaseService();

  void cancelRequests() => _apiService.cancelRequests();

  /// The ordered, published home sections, server-first with a local (Hive)
  /// fallback. A successful fetch refreshes the cache; when the server is
  /// unreachable the last-seen feed is served from the cache instead. A missing
  /// or corrupt cache surfaces the server failure (an empty list is a valid
  /// feed — the admin has not published one yet).
  ///
  /// [lat] / [lng] locate the `nearby_stores` section for a guest; see
  /// [HomeSectionsApiService.getHomeSections].
  Future<Either<Failure, List<HomeSectionModel>>> getHomeSections({
    required String platform,
    required String lang,
    double? lat,
    double? lng,
  }) async {
    // Fetch the raw server `data` object so it can be both cached verbatim and
    // parsed — the cache round-trips through the same parsing the server uses.
    final Either<Failure, Map<String, dynamic>> serverResult =
        await _fetchFromServer(
          platform: platform,
          lang: lang,
          lat: lat,
          lng: lng,
        );

    return serverResult.fold(
      // Server failed (offline or error) → fall back to the cached feed.
      (Failure serverFailure) => _readFromCache(serverFailure),
      // Server succeeded → refresh the cache, then parse.
      (Map<String, dynamic> data) async {
        await _cacheHomeSections(data);
        return Right<Failure, List<HomeSectionModel>>(_parseSections(data));
      },
    );
  }

  /// Runs the guarded server request and returns the raw server `data` object.
  Future<Either<Failure, Map<String, dynamic>>> _fetchFromServer({
    required String platform,
    required String lang,
    double? lat,
    double? lng,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _apiService.getHomeSections(
        platform: platform,
        lang: lang,
        lat: lat,
        lng: lng,
      );

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

  /// Persists the raw feed [data] payload. Best-effort: a cache write failure is
  /// a side effect, not part of the result, so it is swallowed.
  ///
  // ponytail: single-slot cache overwritten on every success and never expired;
  // the feed varies by lang/lat/lng but the cache ignores that. Key by
  // lang/location if stale nearby-stores or wrong-language offline becomes a
  // real complaint.
  Future<void> _cacheHomeSections(Map<String, dynamic> data) async {
    try {
      await _databaseService.saveHomeSections(jsonEncode(data));
    } catch (_) {
      // Intentionally ignored — caching must never break a successful fetch.
    }
  }

  /// Serves the cached feed when the server is unreachable. A missing or corrupt
  /// cache surfaces the original [serverFailure].
  Future<Either<Failure, List<HomeSectionModel>>> _readFromCache(
    Failure serverFailure,
  ) async {
    try {
      final String? cached = _databaseService.getHomeSections();
      if (cached == null) {
        return Left<Failure, List<HomeSectionModel>>(serverFailure);
      }

      final Map<String, dynamic> data =
          jsonDecode(cached) as Map<String, dynamic>;
      return Right<Failure, List<HomeSectionModel>>(_parseSections(data));
    } catch (_) {
      return Left<Failure, List<HomeSectionModel>>(serverFailure);
    }
  }

  /// Parses the raw server `data` object into the ordered section list — the
  /// same mapping for a live response and a cached one.
  List<HomeSectionModel> _parseSections(Map<String, dynamic> data) {
    final List<dynamic> rawSections =
        data['sections'] as List<dynamic>? ?? <dynamic>[];
    return rawSections
        .whereType<Map<String, dynamic>>()
        .map(HomeSectionModel.fromJson)
        .toList();
  }
}
