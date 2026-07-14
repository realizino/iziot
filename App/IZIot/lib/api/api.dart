import 'dart:convert';
import 'dart:io';
import 'package:iziot/Data/Colors/App_Colors.dart';
import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/Data_Storage/Data_Saver.dart';
import 'package:iziot/Models/Chat/Chat_Model.dart';
import 'package:iziot/Models/Link/Link_Model.dart';
import 'package:iziot/Models/Notification/Notification_Model.dart';
import 'package:iziot/Models/User/ReadUser_Model.dart';
import 'package:iziot/Models/User/SaveUser_Model.dart';
import 'package:iziot/Models/User/User_Model.dart';
import 'package:iziot/Screens/activity_home.dart';
import 'package:iziot/Screens/Login/activity_signupdone.dart';
import 'package:iziot/Screens/activity_user_is_access_is_denid.dart';
import 'package:iziot/Screens/Login/activity_verify.dart';
import 'package:iziot/Server/Server.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../l10n/app_localizations.dart';


class api
{

  //Get config start
  Future<String> Config(BuildContext context) async
  {
    if(Strings.Config.isEmpty)
    {
      var result = await Server().Fetch_Get(context, "Config", false, false);
      Strings.Config = jsonDecode(result["data"]);
      return result["data"];
    }
    else
    {
      return Strings.Config.toString();
    }
  }
  //Get config end


}