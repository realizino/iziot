import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../../Data/Strings/Strings.dart';
import '../../Server/Server.dart';
import '../../Services/DeviceData/getDeviceData.dart';
import '../../l10n/app_localizations.dart';

class api_signup
{



  //Get Signup step one api start
  Future<bool> GetSingup(BuildContext context,String username,String password,String email) async
  {
    //Get Firebase token
    String? fcm_token = "-";
    Map<String, String> deviceData = {};

    try
    {
      deviceData = await getDeviceData();
    }
    catch(e)
    {
      // print("Errrrror : "+e.toString());
    }

    try
    {
      if (!kIsWeb) {
        fcm_token = await FirebaseMessaging.instance.getToken();
      }
    }
    catch(e)
    {
      // print("Errrrror : "+e.toString());
    }

    // print("Nrrrror : "+fcm_token.toString());
    // print("Nrrrror : "+deviceData.toString());

    Map<String,dynamic> Data={
      "username":username,
      "password":password,
      "fcm":fcm_token,
      "device_name":deviceData['device_name'],
      "device_type":deviceData['device_type'],
      "os_version":deviceData['os_version'],
      "app_version":deviceData['app_version'],
      "username":username,
      "password":password,
      "email":email,
      "languagee":AppLocalizations.of(context)!.language
    };



    //Get fetech login data from server
    var result=await Server().Fetch_Post(
        context,
        "Signup",
        Data,
        false,
        false
    );

    //Get convert result to json
    var data=jsonDecode(result["data"].toString());

    //check result status
    if(data["status"]=="200") {
      Strings.UT_Token=data["token"].toString();
      Strings.DeviceToken=data["device"].toString();
      return true;
    }

    return false;
  }
  //Get Signup step one api end


  //Get singup verify start
  Future<bool> GetCheckVerifyCode(BuildContext context,String code) async
  {
    //Get fetech login data from server
    var result=await Server().Fetch_Post(
        context,
        "SignupVerify",
        {"v_code":code,"ut":Strings.UT_Token,'device':Strings.DeviceToken},
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
  //Get singup verify end


  //Get signup done start
  Future<bool> Signupdone(BuildContext context,String name,String family,String bio,String phone) async
  {
    //Get fetech login data from server
    var result=await Server().Fetch_Post(
        context,
        "SignupSubmit",
        {
          "ut":Strings.UT_Token ,
          "name":name ,
          "family":family ,
          "bio":bio ,
          "phone":phone
        },
        false,
        false
    );

    //Get convert result to json
    var data=jsonDecode(result["data"].toString());

    if(data["status"]=="200")
    {
      Strings.Token=data["token"];
      Strings.UT_Token=data["token"];
      return true;
    }
    else if(data["status"]=="403")
    {
      Server().Terminate(context);
      return false;
    }
    else
    {
      return false;
    }

  }
//Get signup done end


}