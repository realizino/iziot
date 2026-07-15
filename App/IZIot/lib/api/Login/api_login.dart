import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../Data/Colors/App_Colors.dart';
import '../../Data/Strings/Strings.dart';
import '../../Data_Storage/Data_Saver.dart';
import '../../Models/Notification/Notification_Model.dart';
import '../../Models/User/User_Model.dart';
import '../../Screens/activity_home.dart';
import '../../Screens/Login/activity_signupdone.dart';
import '../../Screens/activity_user_is_access_is_denid.dart';
import '../../Screens/Login/activity_verify.dart';
import '../../Server/Server.dart';
import '../../Services/DeviceData/getDeviceData.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';

class api_login
{

  //Get Login api function start
  Future<void> GetLogin(BuildContext context,String username,String password) async
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
      "languagee":MyApp.language
    };





    //Get fetech login data from server
    var result=await Server().Fetch_Post(
        context,
        "Login",
        Data,
        false,
        false
    );

    if(jsonDecode(result["data"].toString())["status"].toString()=="200")
    {
      Data_Sever.Save_Data("tk", jsonDecode(result["data"].toString())["token"].toString());
      Strings.Token=jsonDecode(result["data"].toString())["token"].toString();

      //Get fetch user data
      User_Model user_data = await GetUserData(context);

      if(user_data.status=="1")
      {
        if(user_data.verify_check=="0")
        {
          Strings.UT_Token=user_data.loginToken;
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => activity_verify( email: user_data.email, )), (
              route) => false);
        }
        else
        {
          if(user_data.name.isEmpty || user_data.family.isEmpty || user_data.phone.isEmpty || user_data.bio.isEmpty)
          {
            Strings.UT_Token=user_data.loginToken;
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => activity_signupdone()), (
                route) => false);
          }
          else
          {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => activity_home()), (
                route) => false);
          }
        }

      }
      else
      {
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (context) => activity_user_is_access_is_denid()), (
            route) => false);
      }

    }
    else
    {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.loginisinvalid,
          backgroundColor: App_Colors.Red_Color,
          gravity: ToastGravity.BOTTOM,
          webPosition: "bottom",
          webBgColor: App_Colors.Red_String_Color,
          toastLength: Toast.LENGTH_SHORT,
          textColor: App_Colors.White_Color,
          fontSize: 16.0
      );
    }

  }
//Get Login api function end


  //Get user data start
  Future<User_Model> GetUserData(BuildContext context) async
  {
    //Get fetech user data from server
    var result=await Server().Fetch_Post(
        context,
        "User",
        {
        },
        true,
        false
    );

    //Get convert result to json
    var data=jsonDecode(result["data"].toString());
    var output = User_Model.fromJson(data["user"]);

    Strings.UserData=output;

    return output;
  }
//Get user data end


//Get logout start
  Future<bool> Logout(BuildContext context) async
  {
    //Get fetech user data from server
    // Server().Fetch_Get(
    //     context,
    //     "Logout",
    //     true,
    //     false
    // );

    return true;
  }
//Get logout end



}