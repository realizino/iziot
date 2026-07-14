import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../../Data/Strings/Strings.dart';
import '../../Models/Link/Link_Model.dart';
import '../../Server/Server.dart';

class api_links
{

  //Get user all links start
  Future<List<Link_Model>> GetAllLinks(BuildContext context) async
  {
    try {
      //Get fetech user data from server
      var result = await Server().Fetch_Get(
          context,
          "Links",
          true,
          false
      );

      //Get convert result to json
      String data1 = result["data"].toString();
      List<dynamic> data2 = jsonDecode(data1.toString())["data"];
      List<Link_Model> out = [];

      for (int i = 0; i < data2.length; i++) {
        out.add(Link_Model.fromjson(data2[i]));
      }

      return out;
    }
    catch(e)
    {
      print("Link Error : "+e.toString());
      return [];
    }
  }
  //Get user all links end


  //Add new link api start
  Future<bool> AddNewLink(BuildContext context,String link) async
  {
    //Get fetech user data from server
    var result=await Server().Fetch_Post(
        context,
        "AddNewLink",
        {
          "link":link
        },
        true,
        false
    );

    return true;

  }
  //Add new link api end


  //Remove link api start
  Future<bool> RemoveLink(BuildContext context,String link_id) async
  {
    //Get fetech user data from server
    var result=await Server().Fetch_Post(
        context,
        "Links/Remove",
        {
          "link_id":link_id
        },
        true,
        false
    );

    return true;
  }
//Remove link api end


//Add new link api start
  Future<bool> AddNewMap(BuildContext context,String lat,String lng) async
  {
    //Get fetech user data from server
    var result=await Server().Fetch_Post(
        context,
        "AddNewMap",
        {
          "lat":lat,
          "lng":lng
        },
        true,
        false
    );

    Strings.UserData.lat=lat;
    Strings.UserData.lng=lng;

    return true;
  }
//Add new link api end



  //Add new link api start
  Future<bool> RemoveMap(BuildContext context) async
  {
    //Get fetech user data from server
    var result=await Server().Fetch_Post(
        context,
        "RemoveMap",
        {},
        true,
        false
    );

    Strings.UserData.lat="";
    Strings.UserData.lng="";

    return true;

  }
//Add new link api end


}