import 'package:equatable/equatable.dart';

/// The support ticket returned by `POST /api/v1/me/support-tickets`
/// (the `data.ticket` object of the response).
class ComplaintResponseModel extends Equatable {
  final int? id;
  final String? ticketNumber;
  final int? orderId;
  final String? title;
  final String? description;
  final String? category;
  final String? status;
  final bool? canAdminReply;
  final List<String> allowedNextStatuses;
  final List<String> statusSelectOptions;
  final ComplaintTicketUser? user;
  final String? priority;
  final bool? canReopen;
  final int? reopenCount;
  final int? maxReopens;
  final String? assignedAt;
  final List<Map<String, dynamic>> replies;
  final List<ComplaintTicketAttachment> attachments;
  final List<ComplaintTicketStatusHistory> statusHistory;
  final int? repliesCount;
  final String? processingStartedAt;
  final String? underReviewAt;
  final String? closedAt;
  final String? lastAdminReplyAt;
  final String? createdAt;
  final String? updatedAt;

  const ComplaintResponseModel({
    this.id,
    this.ticketNumber,
    this.orderId,
    this.title,
    this.description,
    this.category,
    this.status,
    this.canAdminReply,
    this.allowedNextStatuses = const <String>[],
    this.statusSelectOptions = const <String>[],
    this.user,
    this.priority,
    this.canReopen,
    this.reopenCount,
    this.maxReopens,
    this.assignedAt,
    this.replies = const <Map<String, dynamic>>[],
    this.attachments = const <ComplaintTicketAttachment>[],
    this.statusHistory = const <ComplaintTicketStatusHistory>[],
    this.repliesCount,
    this.processingStartedAt,
    this.underReviewAt,
    this.closedAt,
    this.lastAdminReplyAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ComplaintResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ComplaintResponseModel();
    }

    return ComplaintResponseModel(
      id: (json['id'] as num?)?.toInt(),
      ticketNumber: json['ticket_number']?.toString(),
      orderId: (json['order_id'] as num?)?.toInt(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      category: json['category']?.toString(),
      status: json['status']?.toString(),
      canAdminReply: json['can_admin_reply'] as bool?,
      allowedNextStatuses: _stringList(json['allowed_next_statuses']),
      statusSelectOptions: _stringList(json['status_select_options']),
      user: json['user'] is Map<String, dynamic>
          ? ComplaintTicketUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      priority: json['priority']?.toString(),
      canReopen: json['can_reopen'] as bool?,
      reopenCount: (json['reopen_count'] as num?)?.toInt(),
      maxReopens: (json['max_reopens'] as num?)?.toInt(),
      assignedAt: json['assigned_at']?.toString(),
      replies: (json['replies'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .toList(),
      attachments: (json['attachments'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(ComplaintTicketAttachment.fromJson)
          .toList(),
      statusHistory: (json['status_history'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(ComplaintTicketStatusHistory.fromJson)
          .toList(),
      repliesCount: (json['replies_count'] as num?)?.toInt(),
      processingStartedAt: json['processing_started_at']?.toString(),
      underReviewAt: json['under_review_at']?.toString(),
      closedAt: json['closed_at']?.toString(),
      lastAdminReplyAt: json['last_admin_reply_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) {
      return const <String>[];
    }
    return raw.map((dynamic e) => e.toString()).toList();
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        ticketNumber,
        orderId,
        title,
        description,
        category,
        status,
        canAdminReply,
        allowedNextStatuses,
        statusSelectOptions,
        user,
        priority,
        canReopen,
        reopenCount,
        maxReopens,
        assignedAt,
        replies,
        attachments,
        statusHistory,
        repliesCount,
        processingStartedAt,
        underReviewAt,
        closedAt,
        lastAdminReplyAt,
        createdAt,
        updatedAt,
      ];
}

/// The `user` object nested inside a ticket.
class ComplaintTicketUser extends Equatable {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;

  const ComplaintTicketUser({
    this.id,
    this.name,
    this.email,
    this.phone,
  });

  factory ComplaintTicketUser.fromJson(Map<String, dynamic> json) {
    return ComplaintTicketUser(
      id: (json['id'] as num?)?.toInt(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
    );
  }

  @override
  List<Object?> get props => <Object?>[id, name, email, phone];
}

/// A stored file returned inside a ticket's `attachments` list.
class ComplaintTicketAttachment extends Equatable {
  final int? id;
  final String? originalName;
  final String? mimeType;
  final String? extension;
  final int? size;
  final Map<String, dynamic>? meta;
  final String? downloadUrl;
  final String? createdAt;

  const ComplaintTicketAttachment({
    this.id,
    this.originalName,
    this.mimeType,
    this.extension,
    this.size,
    this.meta,
    this.downloadUrl,
    this.createdAt,
  });

  factory ComplaintTicketAttachment.fromJson(Map<String, dynamic> json) {
    return ComplaintTicketAttachment(
      id: (json['id'] as num?)?.toInt(),
      originalName: json['original_name']?.toString(),
      mimeType: json['mime_type']?.toString(),
      extension: json['extension']?.toString(),
      size: (json['size'] as num?)?.toInt(),
      meta: json['meta'] is Map<String, dynamic>
          ? json['meta'] as Map<String, dynamic>
          : null,
      downloadUrl: json['download_url']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        originalName,
        mimeType,
        extension,
        size,
        meta,
        downloadUrl,
        createdAt,
      ];
}

/// A single entry of a ticket's `status_history`.
class ComplaintTicketStatusHistory extends Equatable {
  final int? id;
  final String? fromStatus;
  final String? toStatus;
  final String? changedByActorType;
  final int? changedByActorId;
  final String? note;
  final String? createdAt;

  const ComplaintTicketStatusHistory({
    this.id,
    this.fromStatus,
    this.toStatus,
    this.changedByActorType,
    this.changedByActorId,
    this.note,
    this.createdAt,
  });

  factory ComplaintTicketStatusHistory.fromJson(Map<String, dynamic> json) {
    return ComplaintTicketStatusHistory(
      id: (json['id'] as num?)?.toInt(),
      fromStatus: json['from_status']?.toString(),
      toStatus: json['to_status']?.toString(),
      changedByActorType: json['changed_by_actor_type']?.toString(),
      changedByActorId: (json['changed_by_actor_id'] as num?)?.toInt(),
      note: json['note']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        fromStatus,
        toStatus,
        changedByActorType,
        changedByActorId,
        note,
        createdAt,
      ];
}
