import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../Data/Strings/Strings.dart';
import '../../Data_Storage/Data_Saver.dart';
import '../../Models/User/User_Model.dart';
import '../../Screens/activity_home.dart';
import '../../Screens/Login/activity_signupdone.dart';
import '../../Server/Server.dart';
import '../../Services/DeviceData/getDeviceData.dart';
import '../../main.dart';
import '../Login/api_login.dart';

class api_google_login {

  Future<bool> LoginOrSignup(BuildContext context, String idToken, {
    String? email,
    String? displayName,
  }) async {

    String? fcm_token = "-";
    Map<String, String> deviceData = {};

    try { deviceData = await getDeviceData(); } catch (e) {}

    if (!kIsWeb) {
      try { fcm_token = await FirebaseMessaging.instance.getToken(); } catch (e) {}
    }

    final nameParts = (displayName ?? "").trim().split(" ");
    final name   = nameParts.isNotEmpty ? nameParts.first : "";
    final family = nameParts.length > 1  ? nameParts.sublist(1).join(" ") : "";

    Map<String, dynamic> data = {
      "id_token":    idToken,
      "email":       email ?? "",
      "name":        name,
      "family":      family,
      "fcm":         fcm_token,
      "device_name": deviceData['device_name'],
      "device_type": deviceData['device_type'],
      "os_version":  deviceData['os_version'],
      "app_version": deviceData['app_version'],
      "languagee":   MyApp.language,
    };

    var result = await Server().Fetch_Post(
      context,
      "GoogleAuth",
      data,
      false,
      false,
    );

    if (result["status"] != 200) return false;

    var response = jsonDecode(result["data"].toString());

    if (response["status"] != "200") return false;

    Strings.Token = response["token"].toString();
    Data_Sever.Save_Data("tk", Strings.Token);

    User_Model user_data = await api_login().GetUserData(context);

    if (!context.mounted) return false;

    bool needProfile = response["need_profile"] == true;

    if (needProfile ||
        user_data.name.isEmpty ||
        user_data.family.isEmpty ||
        user_data.phone.isEmpty ||
        user_data.bio.isEmpty) {
      Strings.UT_Token = user_data.login_token;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => activity_signupdone()),
            (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => activity_home()),
            (route) => false,
      );
    }

    return true;
  }

}