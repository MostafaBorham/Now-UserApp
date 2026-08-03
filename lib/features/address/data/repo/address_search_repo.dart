import 'package:dartz/dartz.dart';
import 'package:nowdelivery_user_app/core/database/database_exceptions.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/local/database/address_search_database_service.dart';

/// Recent-keyword operations of the address search (local, Hive-backed).
///
/// Mirrors `SearchRepo` — the database service only reads/writes raw values,
/// this repo owns error handling and the recents rules. Every method returns
/// the up-to-date `List<String>` (most-recent first) on `Right`, so callers can
/// render the result without a second read. No connectivity check: recents are
/// local-only.
///
/// Unlike product recents there is no `filterRecentSearch` here: as soon as the
/// address search field holds text the recents give way to the Places results,
/// so there is nothing to filter.
class AddressSearchRepo {
  final AddressSearchDatabaseService _databaseService =
      AddressSearchDatabaseService();

  /// The newest [_maxKeywords] entries are kept; older ones are dropped.
  /// Deliberately lower than the product search's 10 — the address recents are
  /// laid out under the search field with no scroll view of their own, so a
  /// long list would squeeze the results area.
  static const int _maxKeywords = 5;

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
