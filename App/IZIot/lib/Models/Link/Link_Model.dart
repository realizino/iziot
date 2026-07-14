class Link_Model
{

  int id;
  String link;
  int user_id;

  Link_Model({
    required this.id,
    required this.link,
    required this.user_id,
  });

  factory Link_Model.fromjson(Map<String,dynamic> json)
  {
    return Link_Model(
        id: json["id"],
        link: json["link"],
        user_id: int.parse(json["user_id"].toString())
    );
  }

}