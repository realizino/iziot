import 'dart:async';
import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/Data_Storage/Data_Saver.dart';
import 'package:iziot/Screens/activity_home.dart';
import 'package:iziot/Screens/Login/activity_login.dart';
import 'package:iziot/Screens/activity_onboarding.dart';
import 'package:iziot/Screens/Login/activity_signupdone.dart';
import 'package:iziot/Screens/activity_user_is_access_is_denid.dart';
import 'package:iziot/Screens/Login/activity_verify.dart';
import 'package:iziot/Widget/GetUserPosition.dart';
import 'package:iziot/api/Login/api_login.dart';
import 'package:iziot/api/api.dart';
import 'package:iziot/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'activity_update.dart';

class activity_splash_state extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => activity_splash();
}

class activity_splash extends State<activity_splash_state> {

  var timer_counter = 0;
  var Login_Token = "";

  @override
  void initState() {
    // GetCheckPermissions();
    SplashTimer();
    super.initState();
  }

  // Future<void> GetCheckPermissions() async {
  //   await [
  //     Permission.location,
  //     Permission.storage,
  //     Permission.notification,
  //   ].request();
  // }

  @override
  Widget build(BuildContext context) {
    GetLogin_Check();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Theme.of(context).splashColor,
      statusBarIconBrightness:
      (Strings.darkmod) ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Theme.of(context).splashColor,
      body: Center(
        child: Image.asset('assets/icons/icon.png', width: 120),
      ),
    );
  }

  void GetLogin_Check() async {
    Login_Token = await Data_Sever.Get_Data("Login_Token");
  }

  // ─── Show Language Dialog ───────────────────────────────────────────────────
  Future<void> _showLanguageDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false, // کاربر مجبوره یه زبان انتخاب کنه
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.all(0),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).splashColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildLanguageItem(ctx, "English",  "en", "assets/Images/USA_Flag.png"),
                _buildLanguageItem(ctx, "Persian",  "fa", "assets/Images/Iran_Flag.png"),
                _buildLanguageItem(ctx, "Turkish",  "tr", "assets/Images/Turk_Flag.png"),
                _buildLanguageItem(ctx, "Arabic",   "ar", "assets/Images/Arab_Flag.png"),
                _buildLanguageItem(ctx, "French",   "fr", "assets/Images/Franc_Flag.png"),
                _buildLanguageItem(ctx, "Spanish",  "es", "assets/Images/Snain_Flag.png"),
                _buildLanguageItem(ctx, "Russian",  "ru", "assets/Images/Russia_Flag.png"),
                _buildLanguageItem(ctx, "Chinese",  "zh", "assets/Images/China_Flag.png"),
                _buildLanguageItem(ctx, "Italian",  "it", "assets/Images/Italya_Flag.png"),
                _buildLanguageItem(ctx, "German",    "de", "assets/Images/German_Flag.png"),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageItem(BuildContext ctx, String label, String code, String flagAsset) {
    return TextButton(
      onPressed: () {
        Data_Sever.Save_Data("language", code);
        Strings.language = code;
        MyApp.language = label;
        Navigator.pop(ctx);
      },
      child: SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    color: Theme.of(context).unselectedWidgetColor,
                    fontSize: 16)),
            Image.asset(flagAsset, width: 30),
          ],
        ),
      ),
    );
  }
  // ────────────────────────────────────────────────────────────────────────────

  void SplashTimer() {
    UserPosition().GetUserPosition();

    api().Config(context).then((value) {

      if (Strings.AppVersion == Strings.Config["version"] ||
          Strings.Config["mostupdate"] != "yes") {

        Timer.periodic(const Duration(milliseconds: 1), (time) {
          timer_counter++;
          if (timer_counter == 2) {

            if (Login_Token.length < 5) {
              Data_Sever.Get_Data("review_check").then((value) {

                // ── اولین بار باز شدن اپ ──────────────────────────────────
                if (value.isEmpty || value == "null") {
                  time.cancel();
                  Data_Sever.Save_Data("review_check", "yes");

                  _showLanguageDialog().then((_) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => activity_onboarding()),
                          (Route<dynamic> route) => false,
                    );
                  });

                } else {
                  if (Strings.Token.isEmpty ||
                      Strings.Token.toUpperCase().trim() == "NULL") {
                    time.cancel();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => activity_login()),
                          (Route<dynamic> route) => false,
                    );
                  } else {
                    api_login().GetUserData(context).then((value) {
                      time.cancel();

                      if (value!.status == "1") {
                        if (value!.verify_check == "0") {
                          Strings.UT_Token = value.loginToken;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => activity_verify( email: value.email, )),
                                (Route<dynamic> route) => false,
                          );
                        } else if (value.name.isEmpty ||
                            value.family.isEmpty ||
                            value.phone.isEmpty ||
                            value.bio.isEmpty) {
                          Strings.UT_Token = value.loginToken;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => activity_signupdone()),
                                (route) => false,
                          );
                        }
                        // else if (Strings.DeepLink.isNotEmpty) {
                        //   Navigator.pushAndRemoveUntil(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => activity_display()),
                        //         (Route<dynamic> route) => false,
                        //   );
                        // }
                        else {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => activity_home()),
                                (Route<dynamic> route) => false,
                          );
                        }
                      } else {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  activity_user_is_access_is_denid()),
                              (Route<dynamic> route) => false,
                        );
                      }
                    });
                  }
                }
              });
            } else {
              time.cancel();
            }
          }
        });

      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => activity_update()),
              (Route<dynamic> route) => false,
        );
      }
    });
  }
}