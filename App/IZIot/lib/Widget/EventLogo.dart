import 'package:flutter/cupertino.dart';

Widget EventLogo(String title,{double height = 40})
{

  String address="";

  if(title.contains("پارکینگ")){
    address = "assets/flat/parking-area.png";
  } else if(title.contains("آسانسور")){
    address = "assets/flat/elevator.png";
  } else if(title.contains("شارژ")){
    address = "assets/flat/bag.png";
  } else if(title.contains("آب")){
    address = "assets/flat/water.png";
  } else if(title.contains("برق")){
    address = "assets/flat/electrical-energy.png";
  } else if(title.contains("گاز")){
    address = "assets/flat/natural-gas.png";
  } else if(title.contains("پله")){
    address = "assets/flat/cleaning.png";
  } else if(title.contains("تعمیرات")){
    address = "assets/flat/service.png";
  } else if(title.contains("نگهبانی")){
    address = "assets/flat/guard.png";
  } else if(title.contains("باغبان")){
    address = "assets/flat/gardening.png";
  } else if(title.contains("مدیریت")){
    address = "assets/flat/responsible-business.png";
  } else {
    address = "assets/flat/delivery-box.png";
  }

  // Event icon
  return Image.asset(
    address,
    height: height,
  );
}