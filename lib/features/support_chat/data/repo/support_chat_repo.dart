import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/dio/api_response.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/support_chat/data/datasources/remote/api/support_chat_api_service.dart';
import 'package:nowdelivery_user_app/features/support_chat/data/models/support_chat_message_model.dart';
import 'package:nowdelivery_user_app/features/support_chat/data/models/support_chat_realtime_config.dart';

class SupportChatRepo {
  final SupportChatApiService _api = SupportChatApiService();

  void cancelRequests() => _api.cancelRequests();

  Future<Either<Failure, SupportChatRealtimeConfig>> getRealtimeConfig() =>
      _guard(_api.getRealtimeConfig, SupportChatRealtimeConfig.fromJson);

  Future<Either<Failure, int>> openConversation() =>
      _guard(_api.openConversation, (Map<String, dynamic> data) {
        final dynamic conversation = data['conversation'];
        final dynamic rawId = conversation is Map<String, dynamic>
            ? conversation['id']
            : null;
        final int? id = rawId is int ? rawId : int.tryParse('$rawId');
        if (id == null) {
          throw const FormatException(
            'Support chat response did not include a conversation ID.',
          );
        }
        return id;
      });

  Future<Either<Failure, List<SupportChatMessageModel>>> getMessages(
    int conversationId,
  ) => _guard(
    () => _api.getMessages(conversationId),
    (Map<String, dynamic> data) => _parseMessages(data['messages']),
  );

  Future<Either<Failure, SupportChatMessageModel>> sendMessage({
    required int conversationId,
    required String body,
  }) => _guard(
    () => _api.sendMessage(conversationId: conversationId, body: body),
    (Map<String, dynamic> data) => SupportChatMessageModel.fromJson(
      data['message'] is Map<String, dynamic>
          ? data['message'] as Map<String, dynamic>
          : null,
    ),
  );

  Future<Either<Failure, SupportChatSyncModel>> syncMessages({
    required int conversationId,
    required DateTime changedAfter,
  }) => _guard(
    () => _api.syncMessages(
      conversationId: conversationId,
      changedAfter: changedAfter,
    ),
    SupportChatSyncModel.fromJson,
  );

  Future<Either<Failure, void>> markAsRead(int conversationId) =>
      _guard(() => _api.markAsRead(conversationId), (_) {});

  List<SupportChatMessageModel> _parseMessages(Object? value) {
    if (value is! List) {
      throw const FormatException('Support chat response has no messages.');
    }
    return value
        .map(
          (dynamic item) => SupportChatMessageModel.fromJson(
            item is Map<String, dynamic> ? item : null,
          ),
        )
        .toList();
  }

  Future<Either<Failure, T>> _guard<T>(
    Future<Response<dynamic>> Function() request,
    T Function(Map<String, dynamic> data) parse,
  ) async {
    if (!await ConnectionChecker.isConnected) {
      return Left<Failure, T>(const Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response<dynamic> response = await request();
      return readApiResponse(
        response,
      ).map((Map<String, dynamic> body) => parse(responseData(body)));
    } on DioException catch (exception) {
      return Left<Failure, T>(
        Failure(ApiErrorHandler.messageForDio(exception)),
      );
    } on FormatException {
      return Left<Failure, T>(const Failure(LangKeys.somethingWentWrongKey));
    }
  }
}
