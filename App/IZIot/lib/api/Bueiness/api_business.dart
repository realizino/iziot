import 'dart:convert';
import 'dart:io';
import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/Server/Server.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../Models/Business/Business_Model.dart';

class api_business {

  Future<List<Business_Model>> GetBusinessList(BuildContext context) async {
    try {
      final result = await Server().Fetch_Get(
        context, "Business/List", true, false,
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
          return Business_Model.from_json(e);
        } catch (_) {
          return null;
        }
      })
          .whereType<Business_Model>()
          .toList();

    } catch (e) {
      debugPrint("GetBusinessList error: $e");
      return [];
    }
  }


  Future<bool> CreateBusiness(
      BuildContext context, {
        required String name,
        required String bio,
        required String address,
        required String phone,
        required String lat,
        required String lng,
        required String open_at,
        required String close_at,
        required String language,
        required String keywords,
        XFile? image,
      }) async {
    try {
      var postUri = Uri.parse(Server.Api_Address + "Business/Create");
      var request = http.MultipartRequest("POST", postUri);

      request.headers['Authorization'] = 'Bearer ' + Strings.Token;
      request.fields['name']     = name;
      request.fields['bio']      = bio;
      request.fields['address']  = address;
      request.fields['lat']      = lat;
      request.fields['lng']      = lng;
      request.fields['open_at']  = open_at;
      request.fields['close_at'] = close_at;
      request.fields['language'] = language;
      request.fields['phone'] = phone;
      request.fields['keywords'] = keywords;

      if (image != null) {
        final bytes = await image.readAsBytes();
        request.files.add(
          http.MultipartFile(
            'image',
            Stream.value(bytes),
            bytes.length,
            filename: "business.jpg",
          ),
        );
      }

      var respo = await request.send();
      var response = await respo.stream.bytesToString();
      var data = jsonDecode(response);

      return data["status"] == "200";

    } catch (e) {
      debugPrint("CreateBusiness error: $e");
      return false;
    }
  }


  Future<bool> UpdateBusiness(
      BuildContext context, {
        required int id,
        required String name,
        required String bio,
        required String address,
        required String phone,
        required String lat,
        required String lng,
        required String open_at,
        required String close_at,
        required String language,
        required String keywords,
        XFile? image,
      }) async {
    try {
      var postUri = Uri.parse(Server.Api_Address + "Business/Update");
      var request = http.MultipartRequest("POST", postUri);

      request.headers['Authorization'] = 'Bearer ' + Strings.Token;
      request.fields['id'] = id.toString();
      request.fields['name'] = name;
      request.fields['bio'] = bio;
      request.fields['address'] = address;
      request.fields['lat'] = lat;
      request.fields['lng'] = lng;
      request.fields['open_at'] = open_at;
      request.fields['close_at'] = close_at;
      request.fields['language'] = language;
      request.fields['phone'] = phone;
      request.fields['keywords'] = keywords;

      if (image != null) {
        final bytes = await image.readAsBytes();
        request.files.add(
          http.MultipartFile(
            'image',
            Stream.value(bytes),
            bytes.length,
            filename: "business.jpg",
          ),
        );
      }

      var respo = await request.send();
      var response = await respo.stream.bytesToString();
      var data = jsonDecode(response);

      return data["status"].toString() == "200";
    } catch (e) {
      debugPrint("UpdateBusiness error: $e");
      return false;
    }
  }


  Future<bool> DeleteBusiness(
      BuildContext context, {
        required int id,
      }) async {
    try {
      final result = await Server().Fetch_Post(
        context,
        "Business/Delete",
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
      debugPrint("DeleteBusiness error: $e");
      return false;
    }
  }


}