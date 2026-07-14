
//Change language alert dialog start
import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/Data_Storage/Data_Saver.dart';
import 'package:flutter/material.dart';

Future<void> ShowChangeLanguageAlertDialog(BuildContext context)
{
  return showDialog(
      context: context,
      builder: (Icon){
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.all(0),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Theme.of(context).splashColor,
                borderRadius: BorderRadius.circular(20)
            ),
            child: ListView(
              shrinkWrap: true,
              children: [


                TextButton(
                    onPressed: (){
                      Data_Sever.Save_Data("language", "en");
                      Strings.language="en";
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("English",style: TextStyle( color: Theme.of(context).unselectedWidgetColor , fontSize: 16 ))
                          ,
                          Image.asset("assets/Images/USA_Flag.png",width: 30,)
                        ],
                      ),
                    )
                )
                ,
                TextButton(
                    onPressed: (){
                      Data_Sever.Save_Data("language", "fa");
                      Strings.language="fa";
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Persian",style: TextStyle( color: Theme.of(context).unselectedWidgetColor , fontSize: 16 ))
                          ,
                          Image.asset("assets/Images/Iran_Flag.png",width: 30,)
                        ],
                      ),
                    )
                )
                ,
                TextButton(
                    onPressed: (){
                      Data_Sever.Save_Data("language", "tr");
                      Strings.language="tr";
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Turkic",style: TextStyle( color: Theme.of(context).unselectedWidgetColor , fontSize: 16 ))
                          ,
                          Image.asset("assets/Images/Turk_Flag.png",width: 30,)
                        ],
                      ),
                    )
                )
                ,
                TextButton(
                    onPressed: (){

                    },
                    child: Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Arabic",style: TextStyle( color: Theme.of(context).unselectedWidgetColor , fontSize: 16 ))
                          ,
                          Image.asset("assets/Images/Arab_Flag.png",width: 30,)
                        ],
                      ),
                    )
                )
                ,
                TextButton(
                    onPressed: (){

                    },
                    child: Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("France",style: TextStyle( color: Theme.of(context).unselectedWidgetColor , fontSize: 16 ))
                          ,
                          Image.asset("assets/Images/Franc_Flag.png",width: 30,)
                        ],
                      ),
                    )
                )
                ,
                TextButton(
                    onPressed: (){

                    },
                    child: Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Spanish",style: TextStyle( color: Theme.of(context).unselectedWidgetColor , fontSize: 16 ))
                          ,
                          Image.asset("assets/Images/Snain_Flag.png",width: 30,)
                        ],
                      ),
                    )
                )
                ,
                TextButton(
                    onPressed: (){

                    },
                    child: Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Russian",style: TextStyle( color: Theme.of(context).unselectedWidgetColor , fontSize: 16 ))
                          ,
                          Image.asset("assets/Images/Russia_Flag.png",width: 30,)
                        ],
                      ),
                    )
                )
                ,
                TextButton(
                    onPressed: (){

                    },
                    child: Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Chines",style: TextStyle( color: Theme.of(context).unselectedWidgetColor , fontSize: 16 ))
                          ,
                          Image.asset("assets/Images/China_Flag.png",width: 30,)
                        ],
                      ),
                    )
                )
                ,
                TextButton(
                    onPressed: (){

                    },
                    child: Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Italyian",style: TextStyle( color: Theme.of(context).unselectedWidgetColor , fontSize: 16 ))
                          ,
                          Image.asset("assets/Images/Italya_Flag.png",width: 30,)
                        ],
                      ),
                    )
                )
                ,
                TextButton(
                    onPressed: (){

                    },
                    child: Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Duetch",style: TextStyle( color: Theme.of(context).unselectedWidgetColor , fontSize: 16 ))
                          ,
                          Image.asset("assets/Images/German_Flag.png",width: 30,)
                        ],
                      ),
                    )
                )


              ],
            ),
          ),
        );
      }
  );
}
//Change language alert dialog end
