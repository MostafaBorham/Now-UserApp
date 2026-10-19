import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/support_chat/data/datasources/remote/api/support_chat_endpoints.dart';

class SupportChatApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  void cancelRequests() => _canceller.cancel();

  Future<Response<dynamic>> getRealtimeConfig() => _dio.get<dynamic>(
    SupportChatEndpoints.realtimeConfig,
    cancelToken: _canceller.token,
  );

  Future<Response<dynamic>> openConversation() => _dio.post<dynamic>(
    SupportChatEndpoints.conversations,
    data: <String, dynamic>{},
    cancelToken: _canceller.token,
  );

  Future<Response<dynamic>> openOrderDriverConversation(String orderUuid) =>
      _dio.post<dynamic>(
        SupportChatEndpoints.orderDriverConversation(orderUuid),
        data: <String, dynamic>{},
        cancelToken: _canceller.token,
      );

  Future<Response<dynamic>> getMessages(int conversationId, {String? cursor}) =>
      _dio.get<dynamic>(
        SupportChatEndpoints.messages(conversationId),
        queryParameters: <String, dynamic>{
          'per_page': 100,
          ...?(cursor == null ? null : <String, String>{'cursor': cursor}),
        },
        cancelToken: _canceller.token,
      );

  /// Text only goes as JSON; with photos it's multipart, one `attachments[]`
  /// part per photo.
  Future<Response<dynamic>> sendMessage({
    required int conversationId,
    required String body,
    required List<String> imagePaths,
    required String clientMessageId,
  }) async {
    final Map<String, dynamic> fields = <String, dynamic>{
      if (body.isNotEmpty) 'body': body,
      'client_message_id': clientMessageId,
    };
    if (imagePaths.isEmpty) {
      return _dio.post<dynamic>(
        SupportChatEndpoints.messages(conversationId),
        data: fields,
        cancelToken: _canceller.token,
      );
    }

    final FormData form = FormData.fromMap(fields)
      ..files.addAll(<MapEntry<String, MultipartFile>>[
        // Read off the UI isolate, as the avatar upload does.
        for (final String path in imagePaths)
          MapEntry<String, MultipartFile>(
            'attachments[]',
            await MultipartFile.fromFile(path),
          ),
      ]);
    return _dio.post<dynamic>(
      SupportChatEndpoints.messages(conversationId),
      data: form,
      options: Options(contentType: Headers.multipartFormDataContentType),
      cancelToken: _canceller.token,
    );
  }

  Future<Response<dynamic>> syncMessages({
    required int conversationId,
    required DateTime changedAfter,
    String? cursor,
  }) => _dio.get<dynamic>(
    SupportChatEndpoints.syncMessages(conversationId),
    queryParameters: <String, dynamic>{
      'changed_after': changedAfter.toUtc().toIso8601String(),
      ...?(cursor == null ? null : <String, String>{'cursor': cursor}),
    },
    cancelToken: _canceller.token,
  );

  Future<Response<dynamic>> markAsRead(int conversationId) =>
      _dio.post<dynamic>(
        SupportChatEndpoints.markAsRead(conversationId),
        data: <String, dynamic>{},
        cancelToken: _canceller.token,
      );
}
