import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../Data/Strings/Strings.dart';
import 'IOSCheck.dart';

Widget TopBar(BuildContext context,bool BackAble)
{

  if(IOSCheck())
  {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 70,
      color: Theme.of(context).splashColor,
      child: Stack(
        children: [

          // Center(
          //   child: Image.network(Strings.Config["logo"].toString(),height: 50,),
          // )
          // Center(
          //     child: CachedNetworkImage(
          //         imageUrl: Strings.Config["logo"].toString(),
          //         height: 50,
          //     ),
          // )

          Positioned(
            top: 10,
            right: 20,
            child: Image.asset(
              "assets/icons/r_logo.png",
              key: ValueKey('r_logo'),
              height: 45,
            ),
          )
          ,
          (BackAble)?
          Positioned(
              top: 20,
              left: 20,
              child: InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Icon(Icons.keyboard_arrow_left,size: 28,color: Theme.of(context).secondaryHeaderColor),
              )
          ):Container()

        ],
      ),
    );
  }
  else
  {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 70,
      color: Theme.of(context).splashColor,
      child: Stack(
        children: [

          // Center(
          //   child: Image.network(Strings.Config["logo"].toString(),height: 50,),
          // )
          Center(
            // child: CachedNetworkImage(
            //   imageUrl: Strings.Config["logo"].toString(),
            //   height: 50,
            // ),
            child: Image.asset("assets/icons/r_logo.png",height: 45,),
          )
          ,
          (BackAble)?
          Positioned(
              top: 20,
              left: 20,
              child: InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Icon(Icons.keyboard_arrow_left,size: 28,color: Theme.of(context).secondaryHeaderColor,),
              )
          ):Container()

        ],
      ),
    );
  }

}