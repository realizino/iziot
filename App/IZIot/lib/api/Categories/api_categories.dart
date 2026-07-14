import 'dart:convert';
import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/main.dart';
import 'package:flutter/material.dart';
import '../../Models/Categories/Categories_Model.dart';
import '../../Server/Server.dart';

class api_categories {

  Future<List<Categories_Model>> GetCategories(BuildContext context) async {
    try {
      final result = await Server().Fetch_Get(
        context, "Categories", true, false,
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
          return Categories_Model.from_json(e);
        } catch (_) {
          return null;
        }
      })
          .whereType<Categories_Model>()
          .toList();

    } catch (e) {
      debugPrint("GetCategories error: $e");
      return [];
    }
  }

  Future<void> SetUserCategoriesKeyword(
      BuildContext context, String keywords) async {
    try {
      await Server().Fetch_Post(
        context,
        "SetCategory",
        {"keywords": keywords , "languagee":MyApp.language},
        true,
        false,
      );

      Strings.UserData.keywords = keywords;

    } catch (e) {
      debugPrint("SetUserCategoriesKeyword error: $e");
    }
  }
}