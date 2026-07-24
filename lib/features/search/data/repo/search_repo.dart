import 'package:dartz/dartz.dart';
import 'package:nowdelivery_user_app/core/database/database_exceptions.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/search/data/datasources/local/database/search_database_service.dart';

/// Data operations for the search feature's recent keywords (local, Hive-backed).
///
/// The database service only reads/writes raw values; this repo owns all error
/// handling and formatting. `Left` carries a user-facing message (a
/// [DatabaseException] message key or a raw string — callers apply `.tr()`,
/// which leaves non-key strings untouched). Every method returns the up-to-date
/// `List<String>` of keywords (most-recent first) on `Right`, so callers can
/// render the result without a second read. No connectivity check is done here:
/// recents are local-only.
class SearchRepo {
  final SearchDatabaseService _databaseService = SearchDatabaseService();

  /// The newest [_maxKeywords] entries are kept; older ones are dropped.
  static const int _maxKeywords = 10;

  /// Casts the raw stored value into a `List<String>` (most-recent first),
  /// returning an empty list when nothing is stored yet.
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

  /// Filters the current recent keywords by [searchKey] (case-insensitive
  /// substring match), most-recent first. A blank [searchKey] returns the full
  /// list.
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

  /// Prepends [keyword] to the recent list — de-duplicated (an existing entry
  /// moves to the front) and trimmed to the newest [_maxKeywords].
  Future<Either<Failure, List<String>>> addSearchKey(String keyword) async {
    try {
      final String term = keyword.trim();
      if (term.isEmpty) return Right<Failure, List<String>>(_readKeywords());

      final List<String> updated = <String>[
        term,
        ..._readKeywords().where((String k) => k != term),
      ].take(_maxKeywords).toList();

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
