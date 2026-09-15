import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';

class ComplaintRequestModel extends Equatable {

  final String title;


  final String description;


  final String category;


  final List<ComplaintAttachment> attachments;

  const ComplaintRequestModel({
    this.title = _defaultTitle,
    this.description = '',
    this.category = _defaultCategory,
    this.attachments = const <ComplaintAttachment>[],
  });


  static const String _defaultTitle = 'ticket';
  static const String _defaultCategory = 'orders_and_banners';





  static Future<ComplaintRequestModel> fromComplaintInputs({
    required String description,
    required List<File> images,
  }) async {
    final List<ComplaintAttachment> attachments = <ComplaintAttachment>[];
    for (final File image in images) {
      attachments.add(await ComplaintAttachment.fromFile(image));
    }

    return ComplaintRequestModel(
      description: description,
      attachments: attachments,
    );
  }

  ComplaintRequestModel copyWith({
    String? title,
    String? description,
    String? category,
    List<ComplaintAttachment>? attachments,
  }) {
    return ComplaintRequestModel(
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      attachments: attachments ?? this.attachments,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
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
        description,
        category,
        attachments,
      ];
}



class ComplaintAttachment extends Equatable {
  final String fileName;
  final String fileData;

  const ComplaintAttachment({
    required this.fileName,
    required this.fileData,
  });



  static Future<ComplaintAttachment> fromFile(File file) async {
    final List<int> bytes = await file.readAsBytes();
    final String fileName = file.uri.pathSegments.last;
    return ComplaintAttachment(
      fileName: fileName,
      fileData: 'data:${_mimeTypeFor(fileName)};base64,${base64Encode(bytes)}',
    );
  }



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
