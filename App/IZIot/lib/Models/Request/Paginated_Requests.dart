// Wraps Laravel's paginate() response shape: {current_page, data: [...], last_page, total, ...}
import 'package:iziot/Models/Request/Request_Model.dart';

class Paginated_Requests {
  final List<Request_Model> items;
  final int currentPage;
  final int lastPage;
  final int total;

  Paginated_Requests({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory Paginated_Requests.from_json(Map<String, dynamic> json) {
    final List<dynamic> raw = json["data"] ?? [];
    return Paginated_Requests(
      items: raw.map((e) => Request_Model.from_json(e)).toList(),
      currentPage: int.tryParse(json["current_page"].toString()) ?? 1,
      lastPage: int.tryParse(json["last_page"].toString()) ?? 1,
      total: int.tryParse(json["total"].toString()) ?? 0,
    );
  }
}