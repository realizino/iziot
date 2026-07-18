import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iziot/Screens/User/activity_profile.dart';
import 'package:iziot/Widget/TopBar.dart';

Widget HomeTopBar(BuildContext context)
{
  return Stack(
    children: [

      TopBar(context, false)
      ,
      Positioned(
          right: 0,
          child: Container(
            width: 70,
            height: 70,
            child: Center(
              // Builder gives us a context that is a descendant of the Scaffold,
              // so Scaffold.of(context) can find it and open the end drawer.
              child: Builder(
                builder: (context) {
                  return InkWell(
                    onTap: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    child: Icon(
                      Icons.menu,
                      size: 26,
                      color: Theme.of(context).unselectedWidgetColor,
                    ),
                  );
                },
              ),
            ),
          )
      )
      ,
      Positioned(
          left: 0,
          child: Container(
            width: 70,
            height: 70,
            child: Center(
              child: InkWell(
                child: Image.asset(
                  "assets/icons/user_placeholder.png",
                  height: 30,
                ),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> activity_profile() ));
                },
              ),
            ),
          )
      )

    ],
  );
}