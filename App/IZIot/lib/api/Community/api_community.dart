import 'dart:convert';

import 'package:iziot/Data/Strings/Strings.dart';
import 'package:flutter/cupertino.dart';

import '../../Models/User/MapUsers_Model.dart';
import '../../Models/User/SaveUser_Model.dart';
import '../../Server/Server.dart';
import '../../main.dart';

class api_community
{

  //Get all community api
  Future<List<MapUsers_Model>> GetAllCommunity(BuildContext context) async
  {
    //Get fetech user data from server
    var result=await Server().Fetch_Post(
        context,
        "Community",
        {"community":Strings.UserData.community , "languagee" : MyApp.language},
        true,
        false
    );

    //Get convert result to json
    String data1=result["data"].toString();

    List<dynamic> data2=jsonDecode(data1.toString())["data"];

    List<MapUsers_Model> out=[];

    for(int i=0;i<data2.length;i++)
    {
      out.add(MapUsers_Model.from_json(data2[i]));
    }

    return out;
  }



  Future<List<MapUsers_Model>> GetAllCommunityByFilter(
      BuildContext context, {
        String keywords = "",
        int? categoryId,
      }) async {
    Map<String, dynamic> params = {
      "community": Strings.UserData.community,
      "languagee": MyApp.language,
    };

    if (keywords.isNotEmpty) {
      params["keyword"] = keywords;
    }

    if (categoryId != null) {
      params["category_id"] = categoryId;
    }

    var result = await Server().Fetch_Post(
      context,
      "CommunityByKeyWord",
      params,
      true,
      false,
    );

    String data1 = result["data"].toString();
    List<dynamic> data2 = jsonDecode(data1)["data"];

    return data2.map((e) => MapUsers_Model.from_json(e)).toList();
  }



  //Get all community api
  Future<List<MapUsers_Model>> GetAllCommunityByKeyword(BuildContext context,String keywords) async
  {
    //Get fetech user data from server
    var result=await Server().Fetch_Post(
        context,
        "CommunityByKeyWord",
        {"community":Strings.UserData.community , "keyword":keywords , "languagee" : MyApp.language},
        true,
        false
    );

    //Get convert result to json
    String data1=result["data"].toString();
    List<dynamic> data2=jsonDecode(data1.toString())["data"];
    List<MapUsers_Model> out=[];
    for(int i=0;i<data2.length;i++)
    {
      out.add(MapUsers_Model.from_json(data2[i]));
    }
    return out;
  }


}