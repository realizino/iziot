import 'dart:convert';

import 'package:iziot/Server/Server.dart';
import 'package:flutter/material.dart';

import '../../Models/Link/BLink_Model.dart';

class api_business_links {
  Future<List<BLink_Model>> GetBusinessLinks(
      BuildContext context, {
        required int business_id,
      }) async {
    try {
      final result = await Server().Fetch_Post(
        context,
        "BusinessLinks/List",
        {
          "business_id": business_id.toString(),
        },
        true,
        false,
      );

      if (result == null) return [];

      final raw = result["data"];
      if (raw == null) return [];

      dynamic decoded;
      if (raw is String) {
        try {
          decoded = jsonDecode(raw);
        } catch (_) {
          return [];
        }
      } else {
        decoded = raw;
      }

      List<dynamic> list;
      if (decoded is Map && decoded.containsKey("data")) {
        list = decoded["data"] as List<dynamic>? ?? [];
      } else if (decoded is List) {
        list = decoded;
      } else {
        return [];
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((e) {
        try {
          return BLink_Model.from_json(e);
        } catch (_) {
          return null;
        }
      })
          .whereType<BLink_Model>()
          .toList();
    } catch (e) {
      debugPrint("GetBusinessLinks error: $e");
      return [];
    }
  }

  Future<bool> AddBusinessLink(
      BuildContext context, {
        required int business_id,
        required String link,
      }) async {
    try {
      final result = await Server().Fetch_Post(
        context,
        "BusinessLinks/Create",
        {
          "business_id": business_id.toString(),
          "link": link,
        },
        true,
        false,
      );

      if (result == null) return false;

      final raw = result["data"];
      if (raw == null) return false;

      final data = raw is String ? jsonDecode(raw) : raw;

      return data["status"].toString() == "200";
    } catch (e) {
      debugPrint("AddBusinessLink error: $e");
      return false;
    }
  }

  Future<bool> RemoveLink(
      BuildContext context, {
        required int id,
      }) async {
    try {
      final result = await Server().Fetch_Post(
        context,
        "BusinessLinks/Delete",
        {
          "id": id.toString(),
        },
        true,
        false,
      );

      if (result == null) return false;

      final raw = result["data"];
      if (raw == null) return false;

      final data = raw is String ? jsonDecode(raw) : raw;

      return data["status"].toString() == "200";
    } catch (e) {
      debugPrint("RemoveLink error: $e");
      return false;
    }
  }

}