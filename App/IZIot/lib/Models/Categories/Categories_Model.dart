import 'package:iziot/Data/Strings/Strings.dart';

class Categories_Model
{
  int id;
  String title;
  List<Categories_Model> children;

  Categories_Model({
    required this.id,
    required this.title,
    this.children = const [],
  });

  factory Categories_Model.from_json(Map<String, dynamic> json) {

    print("saaaalllam : "+json.toString());

    return Categories_Model(
      id: json["id"],
      title: (Strings.language == "en")?json["title"]:json["title_"+Strings.language],
      children: (json["children"] as List<dynamic>?)
          ?.map((e) => Categories_Model.from_json(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}