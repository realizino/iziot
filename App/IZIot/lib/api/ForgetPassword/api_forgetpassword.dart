import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../../Data/Strings/Strings.dart';
import '../../Server/Server.dart';

class api_forgetpassword
{



  //Get forgetpassword step one api start
  Future<bool> GetForgetPasswordOne(BuildContext context,String email) async
  {
    debugPrint("First forgetpassword");
    //Get fetech login data from server
    var result=await Server().Fetch_Post(
        context,
        "FrogetPassword",
        {"email":email},
        false,
        false
    );

    //Get convert result to json
    var data=jsonDecode(result["data"].toString());

    debugPrint(data.toString());

    //check result status
    if(data["status"]=="200") {
      Strings.UT_Token=data["token"];
      return true;
    }

    return false;
  }
  //Get forgetpassword step one api end


  //Get forgetpassword step two api start
  Future<bool> GetForgetPasswordTwo(BuildContext context,String code) async
  {
    //Get fetech login data from server
    var result=await Server().Fetch_Post(
        context,
        "SignupVerify",
        {"v_code":code,"ut":Strings.UT_Token},
        false,
        false
    );

    //Get convert result to json
    var data=jsonDecode(result["data"].toString());

    if(data["status"]=="200" && data["message"]=="OK")
    {
      return true;
    }

    return false;
  }
  //Get forgetpassword step two api end


  //Get forgetpassword step three api start
  Future<bool> GetForgetPasswordThree(BuildContext context,String password,String repassword) async
  {
    //Get fetech login data from server
    var result=await Server().Fetch_Post(
        context,
        "ResetPassword",
        {
          "password":password,
          "repassword":repassword,
          "ut":Strings.UT_Token
        },
        false,
        true
    );

    //Get convert result to json
    var data=jsonDecode(result["data"].toString());

    if(data["status"]=="200" && data["message"]=="OK")
    {
      return true;
    }

    return false;
  }
//Get forgetpassword step three api end


}