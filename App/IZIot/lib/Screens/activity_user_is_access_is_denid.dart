import 'package:iziot/Server/Server.dart';
import 'package:iziot/Widget/TopBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';

class activity_user_is_access_is_denid extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => activity_user_is_access_is_denid_state();
}

class activity_user_is_access_is_denid_state
    extends State<activity_user_is_access_is_denid> {

  // Initialize function start
  @override
  void initState() {
    super.initState();
  }
  // Initialize function end

  // Main function start
  @override
  Widget build(BuildContext context) {
    // Change status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));

    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: LogoutBtn(context),
        backgroundColor: Color(0XFFF2F2F2),
        body: Column(
          children: [
            TopBar(context, false),
            MainContent(context),
          ],
        ),
      ),
    );
  }
  // Main function end

  // Logout button start
  Widget LogoutBtn(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: TextButton(
          onPressed: () {
            Server().Terminate(context);
          },
          child: Text(
            AppLocalizations.of(context)!.logout,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
  // Logout button end

  // Main content start
  Widget MainContent(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 105,
      color: Colors.white,
      child: Center(
        child: SizedBox(
          width: 210,
          height: 350,
          child: Column(
            children: [
              Image.asset("assets/icons/notaccess.png", width: 165),
              Container(margin: EdgeInsets.all(15)),
              Text(
                AppLocalizations.of(context)!.youraccessisdenied,
                style: TextStyle(fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
// Main content end
}