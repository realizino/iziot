class User_Model
{

  int id;
  String username;
  String name;
  String family;
  String phone;
  String email;
  String bio;
  String date_time;
  String status;
  String website;
  String address;
  String lat;
  String lng;
  String google_search;
  String blue_check;
  String verify_check;
  String login_token;
  String keywords;
  String community;


  User_Model({
    required this.id,
    required this.username,
    required this.name,
    required this.family,
    required this.phone,
    required this.email,
    required this.bio,
    required this.date_time,
    required this.status,
    required this.website,
    required this.address,
    required this.lat,
    required this.lng,
    required this.google_search,
    required this.blue_check,
    required this.verify_check,
    required this.login_token,
    required this.keywords,
    required this.community
  });


  factory User_Model.fromjson(Map<String,dynamic> json)
  {
    return User_Model(
      id: json["id"],
      username: json["username"],
      name: json["name"],
      family: json["family"],
      phone: json["phone"],
      email: json["email"],
      bio: json["bio"],
      date_time: json["date_time"],
      address: json["address"],
      website: json["website"],
      status: json["status"],
      lat: json["lat"],
      lng: json["lng"],
      google_search: json["google_search"],
      blue_check: json["blue_check"],
      verify_check: json["verify_check"],
      login_token: json["login_token"],
      keywords: json["keywords"]?.toString() ?? "",
      community: json["community"]?.toString() ?? "",
    );
  }


}