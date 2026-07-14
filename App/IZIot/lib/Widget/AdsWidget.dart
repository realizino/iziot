import 'package:iziot/Data/Strings/Strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';























Widget AdsWidget(BuildContext context)
{
  debugPrint("image is :"+Strings.Config["ads_image"].toString());
  return InkWell(
    onTap: (){
      launch(Strings.Config["ads_link"].toString());
    },
    child: Container(
      width: MediaQuery.of(context).size.width,
      height: 70,
      child: Image.network(Strings.Config["ads_image"].toString(),width: MediaQuery.of(context).size.width,height: 70,fit: BoxFit.cover),
    ),
  );

}