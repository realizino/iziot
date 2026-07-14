import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Models/Business/Business_Model.dart';
import '../../Models/User/MapUsers_Model.dart';
import '../../Screens/Business/activity_business_display.dart';
import '../../Server/Server.dart';

class api_map_business
{

  Future<void> GetBusiness(BuildContext context,MapUsers_Model user , var mounted) async {

    final result = await Server().Fetch_Post(
      context,
      "Business/GetById",
      {"id": user.id.toString()},
      true,
      false,
      error_react: false,
    );

    if (result["status"] == 200) {
      final data = jsonDecode(result["data"].toString())["data"];
      final business = Business_Model.from_json(data);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => activity_business_display(business: business),
          ),
        );
      }
    }


  }

}