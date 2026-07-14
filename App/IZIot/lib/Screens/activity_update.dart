import 'dart:async';

import 'package:iziot/l10n/app_localizations.dart';
import 'package:iziot/Data/Colors/App_Colors.dart';
import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/Widget/TopBar.dart';
import 'package:iziot/api/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class activity_update extends StatefulWidget
{

  @override
  State<StatefulWidget> createState() => activity_update_state();

}

class activity_update_state extends State<activity_update>
{

  //Initlize function start
  @override
  void initState()
  {
    super.initState();
  }
  //Initlize function end


  //Main function start
  @override
  Widget build(BuildContext context)
  {
    //Change status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness:Brightness.dark,
    ));

    return SafeArea(
        child: Scaffold(
          bottomNavigationBar: DoneBtn(context),
          backgroundColor: Color(0XFFF2F2F2),
          body: Column(
            children: [

              TopBar(context,false)
              ,
              MainContent(context)

            ],
          ),
        )
    );
  }
  //Main function end

  //Getupdate button start
  Widget DoneBtn(BuildContext context)
  {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: TextButton(
          onPressed: (){
            launch(Strings.Config["update_link"].toString());
          },
          child: Text(AppLocalizations.of(context)!.update,style: TextStyle( color: Theme.of(context).colorScheme.surface ,fontSize: 16)),
          style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor
          ),
        ),
      ),
    );
  }
  //Getupdate button end

  //Main content start
  Widget MainContent(BuildContext context)
  {
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

              Image.asset("assets/icons/update.png",width: 165,)
              ,
              Container(
                margin: EdgeInsets.all(15),
              )
              ,
              Text(AppLocalizations.of(context)!.updateapp,style: TextStyle( fontSize: 13 ),textAlign: TextAlign.center,)

            ],
          ),
        ),
      ),
    );
  }
//Main content end

}