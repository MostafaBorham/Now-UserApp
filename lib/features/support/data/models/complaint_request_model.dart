import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';

class ComplaintRequestModel extends Equatable {
  /// The order number the complaint is about, so support can read it at a
  /// glance; [orderId] is the actual link.
  final String title;

  /// The order the ticket is linked to (`order_id`). The backend takes one
  /// ticket per order and answers a second with a translated 422.
  final int? orderId;

  /// Free-text detail the user typed ("tell us more").
  final String description;

  /// Server-side category slug. Fixed for now.
  final String category;

  /// Files attached to the complaint, each carrying its base64 data URI.
  final List<ComplaintAttachment> attachments;

  const ComplaintRequestModel({
    this.title = _defaultTitle,
    this.orderId,
    this.description = '',
    this.category = _defaultCategory,
    this.attachments = const <ComplaintAttachment>[],
  });

  /// Static values the backend expects until the screen collects them.
  static const String _defaultTitle = 'ticket';
  static const String _defaultCategory = 'orders_and_banners';

  /// Builds the request from the raw inputs the File-a-Complaint screen gathers:
  /// the order's [orderId], its [orderNumber] as the title, the free-text
  /// [description] and the picked [images], each read and base64 encoded into a
  /// [ComplaintAttachment]. An empty [images] list yields an empty
  /// [attachments] list; [category] keeps its static value.
  static Future<ComplaintRequestModel> fromComplaintInputs({
    required int? orderId,
    required String? orderNumber,
    required String description,
    required List<File> images,
  }) async {
    final List<ComplaintAttachment> attachments = <ComplaintAttachment>[];
    for (final File image in images) {
      attachments.add(await ComplaintAttachment.fromFile(image));
    }

    return ComplaintRequestModel(
      title: (orderNumber == null || orderNumber.isEmpty)
          ? _defaultTitle
          : orderNumber,
      orderId: orderId,
      description: description,
      attachments: attachments,
    );
  }

  ComplaintRequestModel copyWith({
    String? title,
    int? orderId,
    String? description,
    String? category,
    List<ComplaintAttachment>? attachments,
  }) {
    return ComplaintRequestModel(
      title: title ?? this.title,
      orderId: orderId ?? this.orderId,
      description: description ?? this.description,
      category: category ?? this.category,
      attachments: attachments ?? this.attachments,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'order_id': ?orderId,
      'description': description,
      'category': category,
      'attachments': attachments
          .map((ComplaintAttachment attachment) => attachment.toJson())
          .toList(),
    };
  }

  @override
  List<Object?> get props => <Object?>[
        title,
        orderId,
        description,
        category,
        attachments,
      ];
}

/// A single attachment inside a [ComplaintRequestModel], sent as a base64 data
/// URI (`data:image/png;base64,...`) alongside its original file name.
class ComplaintAttachment extends Equatable {
  final String fileName;
  final String fileData;

  const ComplaintAttachment({
    required this.fileName,
    required this.fileData,
  });

  /// Reads [file] and encodes it as a base64 data URI (`data:<mime>;base64,…`),
  /// pairing it with the file's own name — the exact shape the API expects.
  static Future<ComplaintAttachment> fromFile(File file) async {
    final List<int> bytes = await file.readAsBytes();
    final String fileName = file.uri.pathSegments.last;
    return ComplaintAttachment(
      fileName: fileName,
      fileData: 'data:${_mimeTypeFor(fileName)};base64,${base64Encode(bytes)}',
    );
  }

  /// Maps a file extension to its image MIME type, defaulting to `image/jpeg`
  /// for the (jpg/jpeg or unknown) cases the gallery/camera picker produces.
  static String _mimeTypeFor(String fileName) {
    switch (fileName.split('.').last.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'file_name': fileName,
      'file_data': fileData,
    };
  }

  @override
  List<Object?> get props => <Object?>[fileName, fileData];
}
