import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/dio/api_response.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/utils/isolate/isolate_runner.dart';
import 'package:nowdelivery_user_app/features/home/data/datasources/local/database/home_sections_database_service.dart';
import 'package:nowdelivery_user_app/features/home/data/datasources/remote/api/home_sections_api_service.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';

class HomeSectionsRepo {
  final HomeSectionsApiService _apiService = HomeSectionsApiService();
  final HomeSectionsDatabaseService _databaseService =
      HomeSectionsDatabaseService();

  void cancelRequests() => _apiService.cancelRequests();

  Future<Either<Failure, List<HomeSectionModel>>> getHomeSections({
    required String platform,
    required String lang,
    double? lat,
    double? lng,
  }) async {
    final Either<Failure, String> serverResult = await _fetchFromServer(
      platform: platform,
      lang: lang,
      lat: lat,
      lng: lng,
    );

    return serverResult.fold(
      (Failure serverFailure) => _readFromCache(serverFailure),

      (String body) async {
        final List<HomeSectionModel> sections;
        try {
          // Decoded and mapped to models in one background isolate: the
          // whole parse used to run on the UI thread.
          sections = await IsolateRunner.parseJson<List<HomeSectionModel>>(
            body,
            decodeHomeSections,
          );
        } catch (_) {
          // A 2xx that is not the feed's JSON — fall back as for any failure.
          return _readFromCache(
            const Failure(LangKeys.serverConnectionFailedKey),
          );
        }
        // Cached as it came, so nothing is re-encoded on the UI thread either.
        await _cacheHomeSections(body);
        return Right<Failure, List<HomeSectionModel>>(sections);
      },
    );
  }

  /// The raw response body, once [readApiResponse] has judged the request a
  /// success.
  Future<Either<Failure, String>> _fetchFromServer({
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

      return readApiResponse(
        response,
      ).map((_) => response.data as String? ?? '');
    } on DioException catch (exception) {
      return Left(
        Failure(
          ApiErrorHandler.extractErrorMessage(
            _errorBody(exception.response?.data),
          ),
        ),
      );
    } catch (_) {
      // An exception's text is a Dart error, not a message for the customer.
      return const Left(Failure(LangKeys.serverConnectionFailedKey));
    }
  }

  Future<void> _cacheHomeSections(String body) async {
    try {
      await _databaseService.saveHomeSections(body);
    } catch (_) {}
  }

  Future<Either<Failure, List<HomeSectionModel>>> _readFromCache(
    Failure serverFailure,
  ) async {
    try {
      final String? cached = _databaseService.getHomeSections();
      if (cached == null) {
        return Left<Failure, List<HomeSectionModel>>(serverFailure);
      }

      final List<HomeSectionModel> sections =
          await IsolateRunner.parseJson<List<HomeSectionModel>>(
            cached,
            decodeHomeSections,
          );
      return Right<Failure, List<HomeSectionModel>>(sections);
    } catch (_) {
      return Left<Failure, List<HomeSectionModel>>(serverFailure);
    }
  }

  /// The error body as the map [ApiErrorHandler] reads. The feed is fetched as
  /// plain text, so an error response arrives as a string too.
  static Map<String, dynamic>? _errorBody(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is! String) return null;
    try {
      final Object? decoded = jsonDecode(data);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }
}

/// The feed's sections from a decoded body: the raw response envelope, or the
/// bare `data` object that installs from before the raw-body cache still hold.
/// Runs inside the parse isolate, so it must stay top-level.
@visibleForTesting
List<HomeSectionModel> decodeHomeSections(Object? decoded) {
  final Map<String, dynamic> root = decoded is Map<String, dynamic>
      ? decoded
      : const <String, dynamic>{};
  final Object? data = root['data'];
  final Map<String, dynamic> payload = data is Map<String, dynamic>
      ? data
      : root;
  final List<dynamic> rawSections =
      payload['sections'] as List<dynamic>? ?? <dynamic>[];
  return rawSections
      .whereType<Map<String, dynamic>>()
      .map(HomeSectionModel.fromJson)
      .toList();
}
