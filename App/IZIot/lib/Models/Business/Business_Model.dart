class Business_Model {
  int id;
  String image;
  String name;
  String bio;
  String address;
  String lat;
  String lng;
  String open_at;
  String close_at;
  String status;
  String subscribe_type;
  String create_at;
  int user_id;
  String username;
  String language;
  String community;
  String keywords;
  String phone;

  String check_type;

  Business_Model({
    required this.id,
    required this.image,
    required this.name,
    required this.bio,
    required this.address,
    required this.lat,
    required this.lng,
    required this.open_at,
    required this.close_at,
    required this.status,
    required this.subscribe_type,
    required this.create_at,
    required this.user_id,
    required this.username,
    required this.language,
    required this.community,
    required this.keywords,
    required this.phone,
    required this.check_type,
  });

  factory Business_Model.from_json(Map<String, dynamic> json) {

    print("111111 : "+json.toString());

    return Business_Model(
      id:             json["id"]             ?? 0,
      image:          json["image"]          ?? "",
      name:           json["name"]           ?? "",
      bio:            json["bio"]            ?? "",
      address:        json["address"]        ?? "",
      lat:            json["lat"]            ?? "",
      lng:            json["lng"]            ?? "",
      open_at:        json["open_at"]        ?? "",
      close_at:       json["close_at"]       ?? "",
      status:         json["status"]         ?? "0",
      subscribe_type: json["subscribe_type"] ?? "",
      create_at:      json["create_at"]      ?? "",
      user_id:        int.parse(json["user_id"].toString())        ?? 0,
      username:       json["username"]       ?? "",
      language:       json["language"]       ?? "",
      community:      json["community"]      ?? "",
      keywords:       json["keywords"]       ?? "",
      phone:          json["phone"]          ?? "",
      check_type:     json["check_type"]     ?? "",
    );
  }
}