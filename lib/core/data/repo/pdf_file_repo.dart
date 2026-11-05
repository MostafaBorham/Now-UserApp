import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/data/datasources/remote/file_download_api_service.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:path_provider/path_provider.dart';

class PdfFileRepo {
  final FileDownloadApiService _apiService = FileDownloadApiService();

  void cancelRequests() => _apiService.cancelRequests();

  /// Downloads the PDF at [url] into the temp directory and returns the file's
  /// path, for the in-app viewer. Every failure but no connection is the
  /// viewer's one message: a download route's errors are English-only.
  Future<Either<Failure, String>> download({required String url}) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response<List<int>> response = await _apiService.downloadBytes(
        url: url,
      );
      final List<int>? bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        return const Left(Failure(LangKeys.fileOpenFailedKey));
      }

      final Directory directory = await getTemporaryDirectory();
      // One file, overwritten by the next one opened, so they don't pile up.
      final File file = await File(
        '${directory.path}/viewer.pdf',
      ).writeAsBytes(bytes, flush: true);
      return Right(file.path);
    } catch (_) {
      return const Left(Failure(LangKeys.fileOpenFailedKey));
    }
  }
}
