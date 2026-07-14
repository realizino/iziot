class Request_Model {
  final int id;
  final String title;
  final String description;

  final double? amount_d;
  final String? amount;

  final String? city;
  final String? country;
  final double? lat;
  final double? lng;

  final String language;
  final String? community;
  final String? keywords;

  final String status;

  final int hostUserId;
  final int? clientUserId;

  final String? clientReport;
  final String? hostReport;

  final int? clientRate;
  final int? hostRate;

  final int priorityScore;
  final DateTime? expiresAt;
  final int viewsCount;
  final int responsesCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Raw nested relations — only present when the API eager-loads them (e.g. GetRequestById, GetRequestsList)
  final Map<String, dynamic>? host;
  final Map<String, dynamic>? client;

  Request_Model({
    required this.id,
    required this.title,
    required this.description,
    this.amount,
    this.amount_d,
    this.city,
    this.country,
    this.lat,
    this.lng,
    required this.language,
    this.community,
    this.keywords,
    required this.status,
    required this.hostUserId,
    this.clientUserId,
    this.clientReport,
    this.hostReport,
    this.clientRate,
    this.hostRate,
    required this.priorityScore,
    this.expiresAt,
    required this.viewsCount,
    required this.responsesCount,
    this.createdAt,
    this.updatedAt,
    this.host,
    this.client,
  });

  factory Request_Model.from_json(Map<String, dynamic> json) {
    return Request_Model(
      id: int.tryParse(json["id"].toString()) ?? 0,
      title: json["title"]?.toString() ?? "",
      description: json["description"]?.toString() ?? "",

      amount_d: json["amount"] != null ? double.tryParse(json["amount"].toString()) : null,
      amount: json["amount"]?.toString() ?? "",

      city: json["city"]?.toString(),
      country: json["country"]?.toString(),
      lat: json["lat"] != null ? double.tryParse(json["lat"].toString()) : null,
      lng: json["lng"] != null ? double.tryParse(json["lng"].toString()) : null,

      language: json["language"]?.toString() ?? "",
      community: json["community"]?.toString(),
      keywords: json["keywords"]?.toString(),

      status: json["status"]?.toString() ?? "open",

      hostUserId: int.tryParse(json["host_user_id"].toString()) ?? 0,
      clientUserId: json["client_user_id"] != null
          ? int.tryParse(json["client_user_id"].toString())
          : null,

      clientReport: json["client_report"]?.toString(),
      hostReport: json["host_report"]?.toString(),

      clientRate: json["client_rate"] != null ? int.tryParse(json["client_rate"].toString()) : null,
      hostRate: json["host_rate"] != null ? int.tryParse(json["host_rate"].toString()) : null,

      priorityScore: int.tryParse(json["priority_score"].toString()) ?? 0,
      expiresAt: json["expires_at"] != null ? DateTime.tryParse(json["expires_at"].toString()) : null,
      viewsCount: int.tryParse(json["views_count"].toString()) ?? 0,
      responsesCount: int.tryParse(json["responses_count"].toString()) ?? 0,

      createdAt: json["created_at"] != null ? DateTime.tryParse(json["created_at"].toString()) : null,
      updatedAt: json["updated_at"] != null ? DateTime.tryParse(json["updated_at"].toString()) : null,

      host: json["host"] is Map ? Map<String, dynamic>.from(json["host"]) : null,
      client: json["client"] is Map ? Map<String, dynamic>.from(json["client"]) : null,
    );
  }

  bool get isOpen => status == "open";
  bool get isAssigned => status == "assigned";
  bool get isClosed => status == "closed";
}