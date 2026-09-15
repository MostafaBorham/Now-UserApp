import 'package:dartz/dartz.dart';
import 'package:nowdelivery_user_app/core/data/datasources/local/database/recent_keywords_database_service.dart';
import 'package:nowdelivery_user_app/core/database/database_exceptions.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';













class RecentKeywordsRepo {
  RecentKeywordsRepo({
    required String boxName,
    required String key,
    required this.maxKeywords,
  }) : _databaseService = RecentKeywordsDatabaseService(
         boxName: boxName,
         key: key,
       );

  final RecentKeywordsDatabaseService _databaseService;


  final int maxKeywords;



  List<String> _readKeywords() {
    final dynamic raw = _databaseService.getRecentSearches();
    if (raw is! List) return <String>[];
    return raw.cast<String>().toList();
  }

  Either<Failure, List<String>> getRecentSearches() {
    try {
      return Right<Failure, List<String>>(_readKeywords());
    } catch (_) {
      return Left<Failure, List<String>>(
        const Failure(DatabaseException.readRecentSearchesFailedMessage),
      );
    }
  }



  Either<Failure, List<String>> filterRecentSearch(String searchKey) {
    try {
      final String query = searchKey.trim().toLowerCase();
      final List<String> keywords = _readKeywords();
      if (query.isEmpty) return Right<Failure, List<String>>(keywords);

      return Right<Failure, List<String>>(
        keywords
            .where((String k) => k.toLowerCase().contains(query))
            .toList(),
      );
    } catch (_) {
      return Left<Failure, List<String>>(
        const Failure(DatabaseException.readRecentSearchesFailedMessage),
      );
    }
  }



  Future<Either<Failure, List<String>>> addSearchKey(String keyword) async {
    try {
      final String term = keyword.trim();
      if (term.isEmpty) return Right<Failure, List<String>>(_readKeywords());

      final List<String> updated = <String>[
        term,
        ..._readKeywords().where((String k) => k != term),
      ].take(maxKeywords).toList();

      await _databaseService.saveRecentSearches(updated);
      return Right<Failure, List<String>>(updated);
    } catch (_) {
      return Left<Failure, List<String>>(
        const Failure(DatabaseException.saveRecentSearchesFailedMessage),
      );
    }
  }

  Future<Either<Failure, List<String>>> removeSearchKey(String keyword) async {
    try {
      final List<String> updated = _readKeywords()
          .where((String k) => k != keyword)
          .toList();

      await _databaseService.saveRecentSearches(updated);
      return Right<Failure, List<String>>(updated);
    } catch (_) {
      return Left<Failure, List<String>>(
        const Failure(DatabaseException.saveRecentSearchesFailedMessage),
      );
    }
  }

  Future<Either<Failure, List<String>>> clearAll() async {
    try {
      await _databaseService.clearAll();
      return const Right<Failure, List<String>>(<String>[]);
    } catch (_) {
      return Left<Failure, List<String>>(
        const Failure(DatabaseException.clearRecentSearchesFailedMessage),
      );
    }
  }
}
