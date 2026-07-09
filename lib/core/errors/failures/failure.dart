import 'package:equatable/equatable.dart';

/// Returned on the `Left` side of a repository `Either` when a request fails.
/// Carries the error message (from the API response when available).
class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => <Object?>[message];
}
