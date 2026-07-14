class Chat_Model {
  final int id;
  final String message_type; // 'text' | 'image' | 'file'
  final String content;
  final String? file_hash; // only for image/file messages
  final String date;
  final int status;
  final int seen;
  final String sender; // "1" = me, "0" = other

  final int? reply_to_id;
  final String? reply_to_content;
  final String? reply_to_sender; // "1" = me sent it, "0" = other sent it

  final bool is_deleted;
  final bool is_edited;

  const Chat_Model({
    required this.id,
    this.message_type = 'text',
    required this.content,
    this.file_hash,
    required this.date,
    required this.status,
    required this.seen,
    required this.sender,
    this.reply_to_id,
    this.reply_to_content,
    this.reply_to_sender,
    this.is_deleted = false,
    this.is_edited = false,
  });

  factory Chat_Model.from_json(Map<String, dynamic> json) {
    int parseInt(dynamic v, [int fallback = 0]) =>
        v == null ? fallback : (int.tryParse(v.toString()) ?? fallback);

    String parseString(dynamic v) => v?.toString() ?? '';

    bool parseBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      final s = v.toString().toLowerCase();
      return s == '1' || s == 'true';
    }

    return Chat_Model(
      id: parseInt(json['id']),
      message_type: parseString(json['message_type']).isEmpty
          ? 'text'
          : parseString(json['message_type']),
      content: parseString(json['content']),
      file_hash: json['file_hash']?.toString(),
      date: parseString(json['date']),
      status: parseInt(json['status']),
      seen: parseInt(json['seen']),
      sender: parseString(json['sender']),
      reply_to_id: json['reply_to_id'] != null ? parseInt(json['reply_to_id']) : null,
      reply_to_content: json['reply_to_content']?.toString(),
      reply_to_sender: json['reply_to_sender']?.toString(),
      is_deleted: parseBool(json['is_deleted']),
      is_edited: parseBool(json['is_edited']),
    );
  }

  bool get isMe => sender == '1';
  bool get isImage => message_type == 'image';
  bool get isText => message_type == 'text';

  Chat_Model copyWith({
    int? id,
    String? message_type,
    String? content,
    String? file_hash,
    String? date,
    int? status,
    int? seen,
    String? sender,
    int? reply_to_id,
    String? reply_to_content,
    String? reply_to_sender,
    bool? is_deleted,
    bool? is_edited,
  }) {
    return Chat_Model(
      id: id ?? this.id,
      message_type: message_type ?? this.message_type,
      content: content ?? this.content,
      file_hash: file_hash ?? this.file_hash,
      date: date ?? this.date,
      status: status ?? this.status,
      seen: seen ?? this.seen,
      sender: sender ?? this.sender,
      reply_to_id: reply_to_id ?? this.reply_to_id,
      reply_to_content: reply_to_content ?? this.reply_to_content,
      reply_to_sender: reply_to_sender ?? this.reply_to_sender,
      is_deleted: is_deleted ?? this.is_deleted,
      is_edited: is_edited ?? this.is_edited,
    );
  }
}