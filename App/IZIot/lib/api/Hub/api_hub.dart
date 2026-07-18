import 'dart:convert';
import 'package:flutter/material.dart';
import '../../Models/Hub/Hub_Model.dart';
import '../../Server/Server.dart';

class api_hub
{

  //Add new hub start
  Future<Map<String, dynamic>> AddHub(
      BuildContext context, {
        required String serialNumber,
        required String title,
        required String iotType,
        required String iotModel,
        String status = "Enable",
        String? resolution,
        required String adminNumber,
        String? ipAddress,
        String? username,
        String? password,
        String? lat,
        String? lng,
        String? timezone,
        List<String> attributes = const [],
      }) async
  {
    Map<String, dynamic> Data = {
      "serial_number": serialNumber,
      "title": title,
      "iot_type": iotType,
      "iot_model": iotModel,
      "status": status,
      "resolution": resolution ?? "",
      "admin_number": adminNumber,
      "ip_address": ipAddress ?? "",
      "username": username ?? "",
      "password": password ?? "",
      "lat": lat ?? "",
      "lng": lng ?? "",
      "timezone": timezone ?? "",
      "attribute_inpt": attributes.isNotEmpty ? (attributes.join(",") + ",") : "",
    };
    print("OK1");
    var result = await Server().Fetch_Post(
        context,
        "Hub/Add",
        Data,
        true,
        false
    );
    print("OK2");
    print(result.toString());

    if (result["status"] == 200)
    {
      print("OK3");
      var jsonResponse = jsonDecode(result["data"].toString());
      print("OK4");
      if (jsonResponse["status"].toString() == "200")
      {
        print("OK5");
        return {
          "success": true,
          "hub": Hub_Model.fromJson(jsonResponse["hub"]),
        };
      }
      print("OK6");
      return {"success": false, "message": jsonResponse["message"]};
    }

    print("OK7");
    return {"success": false, "message": result["message"] ?? "Unknown error"};
  }
  //Add new hub end


  //Get hubs list start
  Future<List<Hub_Model>> GetHubs(BuildContext context) async
  {
    var result = await Server().Fetch_Get(
        context,
        "Hub/List",
        true,
        false
    );

    if (result["status"] == 200)
    {
      var jsonResponse = jsonDecode(result["data"].toString());
      if (jsonResponse["status"].toString() == "200" && jsonResponse["hubs"] != null)
      {
        return Hub_Model.fromJsonList(jsonResponse["hubs"]);
      }
    }

    return [];
  }
  //Get hubs list end


  //Get single hub start
  Future<Hub_Model?> GetHub(BuildContext context, int hubId) async
  {
    var result = await Server().Fetch_Get(
        context,
        "Hub/$hubId",
        true,
        false
    );

    if (result["status"] == 200)
    {
      var jsonResponse = jsonDecode(result["data"].toString());
      if (jsonResponse["status"].toString() == "200" && jsonResponse["hub"] != null)
      {
        return Hub_Model.fromJson(jsonResponse["hub"]);
      }
    }

    return null;
  }
  //Get single hub end


  //Update hub start
  Future<Map<String, dynamic>> UpdateHub(
      BuildContext context, {
        required int hubId,
        required String serialNumber,
        required String title,
        required String iotType,
        required String iotModel,
        String status = "Enable",
        String? resolution,
        required String adminNumber,
        String? ipAddress,
        String? username,
        String? password,
        String? lat,
        String? lng,
        String? timezone,
        List<String> attributes = const [],
      }) async
  {
    Map<String, dynamic> Data = {
      "hub_id": hubId.toString(),
      "serial_number": serialNumber,
      "title": title,
      "iot_type": iotType,
      "iot_model": iotModel,
      "status": status,
      "resolution": resolution ?? "",
      "admin_number": adminNumber,
      "ip_address": ipAddress ?? "",
      "username": username ?? "",
      "password": password ?? "",
      "lat": lat ?? "",
      "lng": lng ?? "",
      "timezone": timezone ?? "",
      "attribute_inpt": attributes.isNotEmpty ? (attributes.join(",") + ",") : "",
    };

    var result = await Server().Fetch_Post(
        context,
        "Hub/Update",
        Data,
        true,
        false
    );

    if (result["status"] == 200)
    {
      var jsonResponse = jsonDecode(result["data"].toString());
      if (jsonResponse["status"].toString() == "200")
      {
        return {
          "success": true,
          "hub": Hub_Model.fromJson(jsonResponse["hub"]),
        };
      }
      return {"success": false, "message": jsonResponse["message"]};
    }

    return {"success": false, "message": result["message"] ?? "Unknown error"};
  }
  //Update hub end


  //Delete hub start
  Future<bool> DeleteHub(BuildContext context, int hubId) async
  {
    var result = await Server().Fetch_Post(
        context,
        "Hub/Delete/$hubId",
        {},
        true,
        false
    );

    if (result["status"] == 200)
    {
      var jsonResponse = jsonDecode(result["data"].toString());
      return jsonResponse["status"].toString() == "200";
    }

    return false;
  }
  //Delete hub end



  //Get hub token (only for PROTOCOL-based models) start
  Future<String?> GetHubToken(BuildContext context, int hubId) async
  {
    var result = await Server().Fetch_Get(
        context,
        "Hub/$hubId/Token",
        true,
        false
    );

    if (result["status"] == 200)
    {
      var jsonResponse = jsonDecode(result["data"].toString());
      if (jsonResponse["status"].toString() == "200" && jsonResponse["token"] != null)
      {
        return jsonResponse["token"].toString();
      }
    }

    return null;
  }
  //Get hub token end

}