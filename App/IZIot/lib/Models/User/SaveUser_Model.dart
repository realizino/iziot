class SaveUser_Model
{

  int id;
  String name;
  String family;
  String username;
  String phone;
  String profile_image;


  SaveUser_Model({
    required this.id,
    required this.name,
    required this.family,
    required this.username,
    required this.phone,
    required this.profile_image,
  });


  factory SaveUser_Model.from_json(Map<String, dynamic> json)
  {
    return SaveUser_Model(
      id: json["id"],
      name:          json["name"]          ?? "",
      family:        json["family"]        ?? "",
      username:      json["username"]      ?? "",
      phone:         json["phone"]         ?? "",
      profile_image: json["profile_image"] ?? "",
    );
  }


}