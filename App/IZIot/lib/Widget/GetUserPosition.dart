import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

class UserPosition
{

  static var Loc_Lat=0.0;
  static var Loc_Lng=0.0;
  static var Loc_Sea=0.0;

  Future<void> GetUserPosition() async
  {
    LocationPermission permission;
    bool service_enable=await Geolocator.isLocationServiceEnabled();

    if(!service_enable)
    {
      return Future.error("Not Permission");
    }

    permission=await Geolocator.checkPermission();
    if(permission==LocationPermission.denied)
    {
      permission=await Geolocator.requestPermission();
      if(permission==LocationPermission.denied)
      {
      return Future.error("Not Permission");
      }
    }

    if(permission==LocationPermission.deniedForever)
    {
      return Future.error("Not Permission");
    }

    Position latlng=await Geolocator.getCurrentPosition();
    // debugPrint(latlng.longitude.toString());
    Loc_Lat=latlng.latitude;
    Loc_Lng=latlng.longitude;
    Loc_Sea=latlng.altitude;

  }

}