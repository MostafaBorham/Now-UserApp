import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/favourites/data/repo/favourites_repo.dart';
import 'package:nowdelivery_user_app/features/favourites/viewmodel/product/product_favourite_vm.dart';

/// The heart flips on tap and the request runs behind it. Nothing may treat the
/// flip as confirmed — the Favourites tab drops a card on a confirmed
/// unfavourite, which would dispose the request — and a failure must fall back
/// to the old status.
void main() {
  test('shows the new status at once, confirms it only on success', () async {
    final Completer<Either<Failure, void>> answer =
        Completer<Either<Failure, void>>();
    final ProductFavouriteViewModel vm = ProductFavouriteViewModel(
      const AsyncData<bool>(false),
      7,
      repo: _PendingFavouritesRepo(answer.future),
    );
    // What the icon's listener sees as settled.
    final List<bool> confirmed = <bool>[];
    vm.addListener(
      (AsyncValue<bool> state) =>
          state.whenOrNull(data: (bool value) => confirmed.add(value)),
      fireImmediately: false,
    );

    final Future<void> adding = vm.addToFavourites();
    expect(vm.state.valueOrNull, isTrue);
    expect(confirmed, isEmpty);

    answer.complete(const Right<Failure, void>(null));
    await adding;
    expect(confirmed, <bool>[true]);
    vm.dispose();
  });

  test('a failure drops the optimistic status and reports why', () async {
    final ProductFavouriteViewModel vm = ProductFavouriteViewModel(
      const AsyncData<bool>(false),
      7,
      repo: _PendingFavouritesRepo(
        Future<Either<Failure, void>>.value(
          const Left<Failure, void>(Failure('offline')),
        ),
      ),
    );

    await vm.addToFavourites();
    // No value, so the icon falls back to its last confirmed status.
    expect(vm.state.valueOrNull, isNull);
    expect(vm.state.error, 'offline');
    expect(vm.claimError(), isTrue);
    vm.dispose();
  });
}

class _PendingFavouritesRepo extends Fake implements FavouritesRepo {
  _PendingFavouritesRepo(this._answer);

  final Future<Either<Failure, void>> _answer;

  @override
  Future<Either<Failure, void>> addProductToFavourites({
    required int productId,
  }) =>
      _answer;

  @override
  void cancelRequests() {}
}
