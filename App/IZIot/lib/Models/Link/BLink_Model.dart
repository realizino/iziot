class BLink_Model {
  int id;
  String link;
  String create_at;
  int user_id;
  int business_id;

  BLink_Model({
    required this.id,
    required this.link,
    required this.create_at,
    required this.user_id,
    required this.business_id,
  });

  factory BLink_Model.from_json(Map<String, dynamic> json) {
    return BLink_Model(
      id: json["id"] ?? 0,
      link: json["link"] ?? "",
      create_at: json["create_at"] ?? "",
      user_id: int.parse(json["user_id"].toString()) ?? 0,
      business_id: int.parse(json["business_id"].toString()) ?? 0,
    );
  }
}