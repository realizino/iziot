import 'dart:convert';
import 'package:iziot/l10n/app_localizations.dart';
import 'package:iziot/main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Data/Colors/App_Colors.dart';
import '../Data/Strings/Strings.dart';
import '../Data_Storage/Data_Saver.dart';
import '../Screens/activity_splash.dart';

class Server {
  static String Root_Address = "http://localhost:8080";
  // static String Root_Address = "https://m.bzhub.social";
  static String Api_Address = Root_Address + "/api/V1/";

  Future<Map<String, dynamic>> Fetch_Post(
      BuildContext context,
      String Url,
      Map<String, dynamic> Data,
      bool Auth_Header,
      bool Ract, {
        bool error_react = true,
      }) async {
    try {
      http.Response response;

      if (Auth_Header) {
        response = await http.post(
          Uri.parse(Api_Address + Url),
          body: Data,
          headers: {"Authorization": Strings.Token},
        );
      } else {
        response = await http.post(
          Uri.parse(Api_Address + Url),
          body: Data,
        );
      }

      if(response.statusCode == 500) {
        print((response.body.length > 1024)
            ? response.body.substring(0,1024)
            : response.body.toString());
        return {};
      }

      if (response.statusCode == 200) {
        if (Ract) {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.opration_is_done,
            backgroundColor: App_Colors.Green_Color,
            gravity: ToastGravity.BOTTOM,
            webPosition: "center",
            webBgColor: App_Colors.Green_String_Color,
            toastLength: Toast.LENGTH_SHORT,
            textColor: App_Colors.White_Color,
            fontSize: 16.0,
          );
        }
        return {"data": response.body, "status": 200};
      }

      if (response.statusCode == 401) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.again_auth,
          backgroundColor: App_Colors.Red_Color,
          gravity: ToastGravity.BOTTOM,
          webPosition: "center",
          webBgColor: App_Colors.Red_String_Color,
          toastLength: Toast.LENGTH_SHORT,
          textColor: App_Colors.White_Color,
          fontSize: 16.0,
        );
        await Terminate(context);
        return {"status": response.statusCode};
      }

      String errorMessage = AppLocalizations.of(context)!.have_an_error;

      try {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse["message"] != null) {
          errorMessage = jsonResponse["message"].toString();
        } else if (jsonResponse["data"] != null &&
            jsonResponse["data"]["errors"] != null &&
            jsonResponse["data"]["errors"] is List &&
            jsonResponse["data"]["errors"].length > 0) {
          errorMessage = jsonResponse["data"]["errors"][0]["msg"].toString();
        } else if (jsonResponse["error"] != null) {
          errorMessage = jsonResponse["error"].toString();
        } else if (jsonResponse["errors"] != null) {
          var errors = jsonResponse["errors"];
          if (errors is Map) {
            errorMessage = errors.values.first[0].toString();
          }
        }
      } catch (e) {
        debugPrint("JSON Parse Error: $e");
        errorMessage = AppLocalizations.of(context)!.error_at+" ${response.statusCode}";
      }

      if (error_react) {
        Fluttertoast.showToast(
          msg: errorMessage,
          backgroundColor: App_Colors.Red_Color,
          gravity: ToastGravity.BOTTOM,
          webPosition: "center",
          webBgColor: App_Colors.Red_String_Color,
          toastLength: Toast.LENGTH_SHORT,
          textColor: App_Colors.White_Color,
          fontSize: 16.0,
        );
      }

      return {"status": response.statusCode, "message": errorMessage};
    } catch (e) {
      debugPrint("Network Error: $e");

      if (error_react) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.error_at_connection,
          backgroundColor: App_Colors.Red_Color,
          gravity: ToastGravity.BOTTOM,
          webPosition: "center",
          webBgColor: App_Colors.Red_String_Color,
          toastLength: Toast.LENGTH_SHORT,
          textColor: App_Colors.White_Color,
          fontSize: 16.0,
        );
      }

      return {"status": 0, "error": e.toString()};
    }
  }

  Future<Map<String, dynamic>> Fetch_Get(
      BuildContext context,
      String Url,
      bool Auth_Header,
      bool Ract, {
        bool error_react = true,
      }) async {
    try {
      http.Response response;

      if (Auth_Header) {
        response = await http.get(
          Uri.parse(Api_Address + Url),
          headers: {"Authorization": Strings.Token},
        );
      } else {
        response = await http.get(Uri.parse(Api_Address + Url));
      }

      if(response.statusCode == 500) {
        print((response.body.length > 1024)
            ? response.body.substring(0,1024)
            : response.body.toString());
        return {};
      }

      if (response.statusCode == 200) {
        if (Ract) {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.opration_is_done,
            backgroundColor: App_Colors.Green_Color,
            gravity: ToastGravity.BOTTOM,
            webPosition: "center",
            webBgColor: App_Colors.Green_String_Color,
            toastLength: Toast.LENGTH_SHORT,
            textColor: App_Colors.White_Color,
            fontSize: 16.0,
          );
        }
        return {"data": response.body, "status": 200};
      }

      if (response.statusCode == 401) {
        await Terminate(context);
        return {"status": response.statusCode};
      }

      String errorMessage = AppLocalizations.of(context)!.have_an_error;

      try {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse["message"] != null) {
          errorMessage = jsonResponse["message"].toString();
        } else if (jsonResponse["data"] != null &&
            jsonResponse["data"]["errors"] != null &&
            jsonResponse["data"]["errors"].length > 0) {
          errorMessage = jsonResponse["data"]["errors"][0]["msg"].toString();
        } else if (jsonResponse["error"] != null) {
          errorMessage = jsonResponse["error"].toString();
        }
      } catch (e) {
        errorMessage = AppLocalizations.of(context)!.error_at+"${response.statusCode}";
      }

      // print(response.body.toString());

      if (error_react) {
        Fluttertoast.showToast(
          msg: errorMessage,
          backgroundColor: App_Colors.Red_Color,
          gravity: ToastGravity.BOTTOM,
          webPosition: "center",
          webBgColor: App_Colors.Red_String_Color,
          toastLength: Toast.LENGTH_SHORT,
          textColor: App_Colors.White_Color,
          fontSize: 16.0,
        );
      }

      return {"status": response.statusCode, "message": errorMessage};
    } catch (e) {
      if (error_react) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.error_at_connection,
          backgroundColor: App_Colors.Red_Color,
          gravity: ToastGravity.BOTTOM,
          webPosition: "center",
          webBgColor: App_Colors.Red_String_Color,
          toastLength: Toast.LENGTH_SHORT,
          textColor: App_Colors.White_Color,
          fontSize: 16.0,
        );
      }

      return {"status": 0, "error": e.toString()};
    }
  }

  Future<void> Terminate(BuildContext context) async {
    if (!context.mounted) return;
    await Clear_Token();
    if (!context.mounted) return;

    Data_Sever.Save_Data("language", MyApp.language);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => activity_splash_state()),
          (route) => false,
    );
  }

  Future<void> Clear_Token() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Strings.Token = '';
    } catch (e) {
      debugPrint("Logout failed: $e");
    }
  }
}