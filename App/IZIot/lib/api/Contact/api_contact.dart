import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../../Models/User/SaveUser_Model.dart';
import '../../Server/Server.dart';

class api_contact
{


  //Add new save api start
  Future<bool> AddNewSave(BuildContext context,String username) async
  {
    //Get fetech user data from server
    var result=await Server().Fetch_Post(
        context,
        "AddSave",
        {
          "username":username
        },
        true,
        true
    );

    return true;

  }
  //Add new save api end


  //Get remove save api start
  Future<bool> GetRemoveSave(BuildContext context,String username) async
  {
    //Get fetech user data from server
    var result=await Server().Fetch_Post(
        context,
        "RemoveSave",
        {
          "username":username
        },
        true,
        true
    );

    return true;

  }
  //Get remove save api end


  //Get all saves api start
  Future<List<SaveUser_Model>> GetAllSave(BuildContext context) async
  {
    //Get fetech user data from server
    var result=await Server().Fetch_Get(
        context,
        "GetSaves",
        true,
        false
    );

    //Get convert result to json
    String data1=result["data"].toString();
    List<dynamic> data2=jsonDecode(data1.toString())["data"];
    List<SaveUser_Model> out=[];

    for(int i=0;i<data2.length;i++)
    {
      out.add(SaveUser_Model.from_json(data2[i]));
    }

    return out;
  }
//Get all saves api end


  Future<List<SaveUser_Model>> SearchUsers(BuildContext context, String query) async
  {
    var result = await Server().Fetch_Get(
        context,
        "SearchUsers?q=$query",
        true,
        false
    );

    String data1 = result["data"].toString();
    List<dynamic> data2 = jsonDecode(data1.toString())["data"];
    List<SaveUser_Model> out = [];

    for (int i = 0; i < data2.length; i++)
    {
      out.add(SaveUser_Model.from_json(data2[i]));
    }

    return out;
  }


}