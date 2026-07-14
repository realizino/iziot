import 'package:iziot/Models/Link/Link_Model.dart';

import '../Business/Business_Model.dart';

class ReadUser_Model
{

  int id;
  String name;
  String family;
  String username;
  String phone;
  String bio;
  String blue_check;
  String image;
  String lat;
  String lng;
  List<Link_Model> links;
  bool saved;
  String keywords;
  String community;
  String language;
  List<Business_Model> businesses;

  ReadUser_Model({
    required this.id,
    required this.name,
    required this.family,
    required this.username,
    required this.phone,
    required this.bio,
    required this.blue_check,
    required this.image,
    required this.lat,
    required this.lng,
    required this.links,
    required this.saved,
    required this.keywords,
    required this.community,
    required this.language,
    required this.businesses
  });

  factory ReadUser_Model.fromjson(Map<String,dynamic> json)
  {
    print("SSSS : "+json.toString());
    return ReadUser_Model(
      id: json["id"],
      name: json["name"],
      family: json["family"],
      username: json["username"],
      phone: json["phone"],
      bio: json["bio"],
      blue_check: json["blue_check"],
      image: json["image"],
      lat: json["lat"],
      lng: json["lng"],
      keywords: json["keywords"],
      community: json["community"],
      links: List<Link_Model>.from(json["links"].map((x)=>Link_Model.fromjson(x))),
      saved: json["saved"],
      language: json["language"],
      businesses: List<Business_Model>.from(json["businesses"].map((x) => Business_Model.from_json(x))),
    );
  }

}