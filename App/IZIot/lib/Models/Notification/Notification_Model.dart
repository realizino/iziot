class Notification_Model
{

  int id;
  String title;
  String content;
  String link;
  String from;
  String date;
  int seen;
  int user_id;

  Notification_Model({
    required this.id,
    required this.title,
    required this.content,
    required this.link,
    required this.from,
    required this.date,
    required this.seen,
    required this.user_id,
  });


  factory Notification_Model.from_json(Map<String,dynamic> json)
  {
    return Notification_Model(
        id: json["id"],
        title: json["title"],
        content: json["content"],
        link: json["link"],
        from: json["from"],
        date: json["date"],
        seen: int.parse(json["seen"].toString()),
        user_id: int.parse(json["user_id"].toString())
    );
  }


}