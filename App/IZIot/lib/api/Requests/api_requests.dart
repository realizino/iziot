import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../../Models/Request/Paginated_Requests.dart';
import '../../Models/Request/Request_Model.dart';
import '../../Server/Server.dart';

class api_requests {

  // ─── Helper: build a "?key=value&..." query string, skipping null values ───
  String _buildQuery(Map<String, dynamic> params) {
    final entries = params.entries.where((e) => e.value != null);
    if (entries.isEmpty) return "";
    final query = entries
        .map((e) => "${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value.toString())}")
        .join("&");
    return "?$query";
  }

  // ─── Create Request ────────────────────────────────────────────────────────
  Future<Request_Model?> CreateRequest(
      BuildContext context, {
        required String title,
        required String description,
        required String language,
        double? amount,
        String? city,
        String? country,
        double? lat,
        double? lng,
        String? community,
        String? keywords,
        DateTime? expiresAt,
      }) async {
    try {
      final body = <String, String>{
        "title": title,
        "description": description,
        "language": language,
        if (amount != null) "amount": amount.toString(),
        if (city != null) "city": city,
        if (country != null) "country": country,
        if (lat != null) "lat": lat.toString(),
        if (lng != null) "lng": lng.toString(),
        if (community != null) "community": community,
        if (keywords != null) "keywords": keywords,
        if (expiresAt != null) "expires_at": expiresAt.toIso8601String(),
      };

      final result = await Server().Fetch_Post(context, "Requests/Create", body, true, false);
      if (result["data"] == null) return null;

      final decoded = jsonDecode(result["data"]);
      if (decoded["status"] != "200") return null;

      return Request_Model.from_json(decoded["data"]);
    } catch (e) {
      debugPrint("CreateRequest Error: $e");
      return null;
    }
  }

  // ─── Update Request ────────────────────────────────────────────────────────
  Future<bool> UpdateRequest(
      BuildContext context, {
        required int id,
        String? title,
        String? description,
        double? amount,
        String? city,
        String? country,
        double? lat,
        double? lng,
        String? language,
        String? community,
        String? keywords,
        DateTime? expiresAt,
      }) async {
    try {
      final body = <String, String>{
        "id": id.toString(),
        if (title != null) "title": title,
        if (description != null) "description": description,
        if (amount != null) "amount": amount.toString(),
        if (city != null) "city": city,
        if (country != null) "country": country,
        if (lat != null) "lat": lat.toString(),
        if (lng != null) "lng": lng.toString(),
        if (language != null) "language": language,
        if (community != null) "community": community,
        if (keywords != null) "keywords": keywords,
        if (expiresAt != null) "expires_at": expiresAt.toIso8601String(),
      };

      final result = await Server().Fetch_Post(context, "Requests/Update", body, true, false);
      final decoded = jsonDecode(result["data"]);
      return decoded["status"] == "200";
    } catch (_) {
      return false;
    }
  }

  // ─── Delete Request ────────────────────────────────────────────────────────
  Future<bool> DeleteRequest(BuildContext context, int id) async {
    try {
      final result = await Server().Fetch_Post(context, "Requests/Delete", {
        "id": id.toString(),
      }, true, false);

      final decoded = jsonDecode(result["data"]);
      return decoded["status"] == "200";
    } catch (_) {
      return false;
    }
  }

  // ─── Get Single Request ────────────────────────────────────────────────────
  Future<Request_Model?> GetRequestById(BuildContext context, int id) async {
    try {
      final result = await Server().Fetch_Post(context, "Requests/GetById", {
        "id": id.toString(),
      }, true, false);

      if (result["data"] == null) return null;
      final decoded = jsonDecode(result["data"]);
      if (decoded["status"] != "200") return null;

      return Request_Model.from_json(decoded["data"]);
    } catch (e) {
      debugPrint("GetRequestById Error: $e");
      return null;
    }
  }

  // ─── List / Browse Open Requests ───────────────────────────────────────────
  Future<Paginated_Requests?> GetRequestsList(
      BuildContext context, {
        int page = 1,
        int perPage = 20,
        String? city,
        String? language,
        String? community,
        String? keyword,
      }) async {
    try {
      final query = _buildQuery({
        "page": page,
        "per_page": perPage,
        "city": city,
        "language": language,
        "community": community,
        "keyword": keyword,
      });

      final result = await Server().Fetch_Get(context, "Requests/List$query", true, false);
      if (result["data"] == null) return null;

      final decoded = jsonDecode(result["data"]);
      if (decoded["status"] != "200") return null;

      return Paginated_Requests.from_json(decoded["data"]);
    } catch (e) {
      debugPrint("GetRequestsList Error: $e");
      return null;
    }
  }

  // ─── My Requests (as host) ─────────────────────────────────────────────────
  Future<Paginated_Requests?> GetMyRequests(
      BuildContext context, {
        int page = 1,
        int perPage = 20,
        String? status, // "open" | "assigned" | "closed"
      }) async {
    try {
      final query = _buildQuery({
        "page": page,
        "per_page": perPage,
        "status": status,
      });

      final result = await Server().Fetch_Get(context, "Requests/MyRequests$query", true, false);
      if (result["data"] == null) return null;

      final decoded = jsonDecode(result["data"]);
      if (decoded["status"] != "200") return null;

      return Paginated_Requests.from_json(decoded["data"]);
    } catch (e) {
      debugPrint("GetMyRequests Error: $e");
      return null;
    }
  }

  // ─── My Accepted Requests (as client) ──────────────────────────────────────
  Future<Paginated_Requests?> GetMyAcceptedRequests(
      BuildContext context, {
        int page = 1,
        int perPage = 20,
      }) async {
    try {
      final query = _buildQuery({"page": page, "per_page": perPage});

      final result = await Server().Fetch_Get(context, "Requests/MyAcceptedRequests$query", true, false);
      if (result["data"] == null) return null;

      final decoded = jsonDecode(result["data"]);
      if (decoded["status"] != "200") return null;

      return Paginated_Requests.from_json(decoded["data"]);
    } catch (e) {
      debugPrint("GetMyAcceptedRequests Error: $e");
      return null;
    }
  }

  // ─── Accept Request ────────────────────────────────────────────────────────
  Future<bool> AcceptRequest(BuildContext context, int id) async {
    try {
      final result = await Server().Fetch_Post(context, "Requests/Accept", {
        "id": id.toString(),
      }, true, false);

      final decoded = jsonDecode(result["data"]);
      return decoded["status"] == "200";
    } catch (_) {
      return false;
    }
  }

  // ─── Cancel Assignment ─────────────────────────────────────────────────────
  Future<bool> CancelAssignment(BuildContext context, int id) async {
    try {
      final result = await Server().Fetch_Post(context, "Requests/CancelAssignment", {
        "id": id.toString(),
      }, true, false);

      final decoded = jsonDecode(result["data"]);
      return decoded["status"] == "200";
    } catch (_) {
      return false;
    }
  }

  // ─── Close Request ─────────────────────────────────────────────────────────
  Future<bool> CloseRequest(BuildContext context, int id) async {
    try {
      final result = await Server().Fetch_Post(context, "Requests/Close", {
        "id": id.toString(),
      }, true, false);

      final decoded = jsonDecode(result["data"]);
      return decoded["status"] == "200";
    } catch (_) {
      return false;
    }
  }

  // ─── Feedback: submitted BY the client ABOUT the host ──────────────────────
  Future<bool> SubmitClientFeedback(
      BuildContext context, {
        required int id,
        required int rate,
        String? report,
      }) async {
    try {
      final result = await Server().Fetch_Post(context, "Requests/SubmitClientFeedback", {
        "id": id.toString(),
        "rate": rate.toString(),
        if (report != null) "report": report,
      }, true, false);

      final decoded = jsonDecode(result["data"]);
      return decoded["status"] == "200";
    } catch (_) {
      return false;
    }
  }

  // ─── Feedback: submitted BY the host ABOUT the client ───────────────────────
  Future<bool> SubmitHostFeedback(
      BuildContext context, {
        required int id,
        required int rate,
        String? report,
      }) async {
    try {
      final result = await Server().Fetch_Post(context, "Requests/SubmitHostFeedback", {
        "id": id.toString(),
        "rate": rate.toString(),
        if (report != null) "report": report,
      }, true, false);

      final decoded = jsonDecode(result["data"]);
      return decoded["status"] == "200";
    } catch (_) {
      return false;
    }
  }
}