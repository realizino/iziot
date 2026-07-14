class MapUsers_Model {
  int id;
  String name;
  String family;
  String username;
  String phone;
  String profile_image;
  String lat;
  String lng;
  String type;

  MapUsers_Model({
    required this.id,
    required this.name,
    required this.family,
    required this.username,
    required this.phone,
    required this.profile_image,
    required this.lat,
    required this.lng,
    required this.type,
  });

  factory MapUsers_Model.from_json(Map<String, dynamic> json) {
    return MapUsers_Model(
      id:            json["id"] ?? 0,
      name:          json["name"]          ?? "",
      family:        json["family"]        ?? "",
      username:      json["username"]      ?? "",
      phone:         json["phone"]         ?? "",
      profile_image: json["profile_image"] ?? "",
      lat:           json["lat"]           ?? "",
      lng:           json["lng"]           ?? "",
      type:          json["type"]          ?? "USER",
    );
  }
}