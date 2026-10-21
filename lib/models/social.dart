import 'enums.dart';

class FbComment {
  const FbComment({
    required this.id,
    required this.author,
    required this.text,
    required this.postTitle,
    required this.createdAt,
    this.status = CommentReplyStatus.pending,
    this.draftReply = '',
    this.reply = '',
  });

  final String id;
  final String author;
  final String text;
  final String postTitle;
  final DateTime createdAt;
  final CommentReplyStatus status;
  final String draftReply;
  final String reply;

  FbComment copyWith({
    CommentReplyStatus? status,
    String? reply,
    String? draftReply,
  }) => FbComment(
    id: id,
    author: author,
    text: text,
    postTitle: postTitle,
    createdAt: createdAt,
    status: status ?? this.status,
    draftReply: draftReply ?? this.draftReply,
    reply: reply ?? this.reply,
  );

  factory FbComment.fromJson(Map<String, dynamic> j) => FbComment(
    id: J.s(j['id']),
    author: J.s(j['author']),
    text: J.s(j['text']),
    postTitle: J.s(j['post_title']),
    createdAt: J.dt(j['created_at']),
    status: enumByName(
      CommentReplyStatus.values,
      j['status'],
      CommentReplyStatus.pending,
    ),
    draftReply: J.s(j['draft_reply']),
    reply: J.s(j['reply']),
  );
}

class CommentRule {
  const CommentRule({
    required this.id,
    required this.name,
    required this.keywords,
    required this.action,
    required this.replyTemplate,
    this.enabled = true,
  });

  final String id;
  final String name;
  final List<String> keywords;
  final CommentAction action;
  final String replyTemplate;
  final bool enabled;

  CommentRule copyWith({
    String? name,
    List<String>? keywords,
    CommentAction? action,
    String? replyTemplate,
    bool? enabled,
  }) => CommentRule(
    id: id,
    name: name ?? this.name,
    keywords: keywords ?? this.keywords,
    action: action ?? this.action,
    replyTemplate: replyTemplate ?? this.replyTemplate,
    enabled: enabled ?? this.enabled,
  );

  factory CommentRule.fromJson(Map<String, dynamic> j) => CommentRule(
    id: J.s(j['id']),
    name: J.s(j['name']),
    keywords: (j['keywords'] is List)
        ? (j['keywords'] as List).map((e) => '$e').toList()
        : <String>[],
    action: enumByName(
      CommentAction.values,
      j['action'],
      CommentAction.publicReply,
    ),
    replyTemplate: J.s(j['reply_template']),
    enabled: J.b(j['enabled'], true),
  );
}

class ActivityLog {
  const ActivityLog({
    required this.id,
    required this.message,
    required this.at,
  });
  final String id;
  final String message;
  final DateTime at;

  factory ActivityLog.fromJson(Map<String, dynamic> j) => ActivityLog(
    id: J.s(j['id']),
    message: J.s(j['message']),
    at: J.dt(j['at']),
  );
}

class ModerationSettings {
  const ModerationSettings({
    this.requireApproval = true,
    this.hideSpam = true,
    this.hideAbusive = false,
    this.flagNegative = true,
  });
  final bool requireApproval;
  final bool hideSpam;
  final bool hideAbusive;
  final bool flagNegative;

  ModerationSettings copyWith({
    bool? requireApproval,
    bool? hideSpam,
    bool? hideAbusive,
    bool? flagNegative,
  }) => ModerationSettings(
    requireApproval: requireApproval ?? this.requireApproval,
    hideSpam: hideSpam ?? this.hideSpam,
    hideAbusive: hideAbusive ?? this.hideAbusive,
    flagNegative: flagNegative ?? this.flagNegative,
  );
}
