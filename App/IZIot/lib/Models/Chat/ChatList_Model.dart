class ChatList_Model {
  final int id;
  final String last_text;
  final String last_text_date;
  final String profile_image;
  final String name;
  final String family;
  final String username;

  const ChatList_Model({
    required this.id,
    required this.last_text,
    required this.last_text_date,
    required this.profile_image,
    this.name = '',
    this.family = '',
    this.username = '',
  });

  factory ChatList_Model.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    String s(dynamic v) => v?.toString() ?? '';

    return ChatList_Model(
      id: parseId(json['id']),
      last_text: s(json['last_text']),
      last_text_date: s(json['last_text_date']),
      profile_image: s(json['profile_image']),
      name: s(json['name']),
      family: s(json['family']),
      username: s(json['username']),
    );
  }

  ChatList_Model copyWith({
    int? id,
    String? last_text,
    String? last_text_date,
    String? profile_image,
    String? name,
    String? family,
    String? username,
  }) {
    return ChatList_Model(
      id: id ?? this.id,
      last_text: last_text ?? this.last_text,
      last_text_date: last_text_date ?? this.last_text_date,
      profile_image: profile_image ?? this.profile_image,
      name: name ?? this.name,
      family: family ?? this.family,
      username: username ?? this.username,
    );
  }
}