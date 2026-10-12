import 'package:equatable/equatable.dart';

/// Returned on the `Left` side of a repository `Either` when a request fails.
/// Carries the error message (from the API response when available).
class Failure extends Equatable {
  final String message;

  /// The HTTP status of the rejected request, when the server answered and the
  /// repo passed it on.
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  List<Object?> get props => <Object?>[message, statusCode];
}
