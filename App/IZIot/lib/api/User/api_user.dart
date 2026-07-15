import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../../Data/Strings/Strings.dart';
import '../../Models/User/ReadUser_Model.dart';
import '../../Server/Server.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';

class api_user
{


  //Add new bio api start
  Future<bool> AddNewBio(BuildContext context,String bio) async
  {
    //Get fetech user data from server
    var result=await Server().Fetch_Post(
        context,
        "AddNewBio",
        {
          "bio":bio,
          "languagee":MyApp.language
        },
        true,
        false
    );

    return true;
  }
  //Add new bio api end



  //Add new language api start
  Future<bool> SetLanguage(BuildContext context) async
  {
    //Get fetech user data from server
    var result=await Server().Fetch_Post(
        context,
        "SetLanguage",
        {
          "languagee":MyApp.language
        },
        true,
        false
    );

    return true;
  }
  //Add new bio api end



  //Add new password api start
  Future<bool> AddNewPassword(BuildContext context,String password) async
  {
    //Get fetech user data from server
    var result=await Server().Fetch_Post(
        context,
        "NewPassword",
        {
          "password":password,
          "languagee":MyApp.language
        },
        true,
        false
    );

    return true;
  }
  //Add new password api end


  //Upload new avatar image start
  Future<bool> UploadNewAvatar(BuildContext context,String img) async
  {
    debugPrint(Strings.Token);
    debugPrint(Server.Api_Address+"NewAvatar");
    var postUri = Uri.parse(Server.Api_Address+"NewAvatar");
    var request = new http.MultipartRequest("POST", postUri);

    debugPrint("AddParamerts");
    // request.headers['auth'] = Strings.Token;
    request.headers['Authorization'] = 'Bearer ' + Strings.Token;
    request.files.add(
        new http.MultipartFile(
            'image',
            File(img).readAsBytes().asStream() ,
            File(img).lengthSync(),
            filename: "avatar.jpg"
        )
    );

    var respo = await request.send();
    var response=await respo.stream.bytesToString();

    var data = jsonDecode(response);
    Strings.ProfileImage=data["file_hash"].toString();

    return true;
  }
  //Upload new avatar image end



  //Get user api start
  Future<ReadUser_Model> GetUser(BuildContext context,String username) async
  {
    //Get fetech user data from server
    var result=await Server().Fetch_Get(
        context,
        "GetUser/"+username,
        true,
        false
    );


    var all=jsonDecode(result["data"].toString())["data"];

    ReadUser_Model out=ReadUser_Model.fromjson(all);

    return out;
  }
//Get user api end



//Get user api start
  Future<ReadUser_Model> GetUserById(BuildContext context,String id) async
  {
    //Get fetech user data from server
    var result=await Server().Fetch_Get(
        context,
        "GetUserById/"+id,
        true,
        false
    );


    var all=jsonDecode(result["data"].toString())["data"];

    ReadUser_Model out=ReadUser_Model.fromjson(all);

    return out;
  }
//Get user api end


}