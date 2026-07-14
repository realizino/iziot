import 'package:flutter/cupertino.dart';

import '../../Server/Server.dart';

class api_report
{



  //Add new report api start
  Future<bool> AddReport(BuildContext context,String text,String username) async
  {
    //Get fetech user data from server
    var result=await Server().Fetch_Post(
        context,
        "SubmitReport",
        {
          "text":text,
          "username":username
        },
        true,
        false
    );

    return true;
  }
//Add new report api end



}