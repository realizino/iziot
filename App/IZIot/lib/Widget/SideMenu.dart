import 'package:iziot/Layout/RequestsLayout.dart';
import 'package:iziot/Screens/activity_home.dart';
import 'package:iziot/Screens/User/activity_newlocation.dart';
import 'package:iziot/Screens/User/activity_notifications.dart';
import 'package:iziot/Screens/User/activity_profile.dart';
import 'package:iziot/Screens/activity_splash.dart';
import 'package:iziot/Server/Server.dart';
import 'package:iziot/api/Login/api_login.dart';
import 'package:iziot/api/User/api_user.dart';
import 'package:iziot/api/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Data/Strings/Strings.dart';
import '../Data_Storage/Data_Saver.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';


class SideMenu extends StatefulWidget
{
  final VoidCallback? onNotificationTap;
  const SideMenu({Key? key, this.onNotificationTap}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SideMenu_State();
}


class SideMenu_State extends State<SideMenu>
{

  //Main function start
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
        // bottomNavigationBar:Logo(context),
        backgroundColor: Theme.of(context).splashColor,
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Container(
                  margin: EdgeInsets.only(top: 45,left: 30,right: 30,bottom: 30),
                  child: Center(
                    child: Image.asset("assets/icons/coffe.png",height: 160),
                  ),
                )
                ,
                InkWell(
                  onTap: (){
                    // Navigator.of(context).pushNamed("/Profile");
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>activity_profile()));
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 26,right: 26,bottom: 13,top: 13),
                    child: Row(
                      children: [
                        SvgPicture.asset("assets/icons/user-pen.svg",width: 30,color: Theme.of(context).unselectedWidgetColor)
                        ,
                        Container(
                          margin: EdgeInsets.all(6),
                        )
                        ,
                        Text(AppLocalizations.of(context)!.profile,style: TextStyle( color: Color(0XFF9C9B9D),fontSize: 15 ),)
                      ],
                    ),
                  ),
                )
                ,
                InkWell(
                  onTap: (){

                    // Navigator.of(context).pushNamedAndRemoveUntil("/Location", (route) => false);
                    Navigator.push(context, MaterialPageRoute(builder: (content)=>activity_newlocation()));

                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 26,right: 26,bottom: 13,top: 13),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset("assets/icons/earth-americas.svg",width: 26,color: Theme.of(context).unselectedWidgetColor)
                        ,
                        Container(
                          margin: EdgeInsets.all(6),
                        )
                        ,
                        Text(AppLocalizations.of(context)!.addlocation,style: TextStyle( color: Color(0XFF9C9B9D),fontSize: 15 ),)
                      ],
                    ),
                  ),
                )
                ,
                InkWell(
                  onTap: (){
                    ShowChangeLanguageAlertDialog(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 26,right: 26,bottom: 13,top: 13),
                    child: Row(
                      children: [
                        SvgPicture.asset("assets/icons/language.svg",width: 26,color: Theme.of(context).unselectedWidgetColor)
                        ,
                        Container(
                          margin: EdgeInsets.all(6),
                        )
                        ,
                        Text(AppLocalizations.of(context)!.language,style: TextStyle( color: Color(0XFF9C9B9D),fontSize: 15 ),)
                      ],
                    ),
                  ),
                )
                ,
                InkWell(
                  onTap: (){

                    widget.onNotificationTap?.call();

                    Navigator.push(context, MaterialPageRoute(builder: (context)=> activity_notifications_state() ));

                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 26,right: 26,bottom: 13,top: 13),
                    child: Row(
                      children: [
                        SvgPicture.asset("assets/icons/envelope-dot.svg",width: 26,color: Theme.of(context).unselectedWidgetColor)
                        ,
                        Container(
                          margin: EdgeInsets.all(6),
                        )
                        ,
                        Text(AppLocalizations.of(context)!.messages,style: TextStyle( color: Color(0XFF9C9B9D),fontSize: 15 ),)
                        ,
                        Container(
                          margin: EdgeInsets.all(2),
                        )
                        ,
                        (Strings.UnseenMessagesCount!=0)
                            ?ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            width: 18,
                            height: 18,
                            color: Colors.red,
                            child: Center(
                              child: Text(
                                Strings.UnseenMessagesCount.toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11
                                ),
                              ),
                            ),
                          ),
                        ):Container()

                      ],
                    ),
                  ),
                )
                ,
                InkWell(
                  onTap: (){
                    ShowLawsAlertDialog(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 26,right: 26,bottom: 13,top: 13),
                    child: Row(
                      children: [
                        SvgPicture.asset("assets/icons/gavel.svg",width: 26,color: Theme.of(context).unselectedWidgetColor)
                        ,
                        Container(
                          margin: EdgeInsets.all(6),
                        )
                        ,
                        Text(AppLocalizations.of(context)!.law,style: TextStyle( color: Color(0XFF9C9B9D),fontSize: 15 ),)
                      ],
                    ),
                  ),
                )
                ,
                InkWell(
                  onTap: (){
                    launch("https://izino.ir");
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 26,right: 26,bottom: 13,top: 13),
                    child: Row(
                      children: [
                        SvgPicture.asset("assets/icons/comment-question.svg",width: 26,color: Theme.of(context).unselectedWidgetColor)
                        ,
                        Container(
                          margin: EdgeInsets.all(6),
                        )
                        ,
                        Text(AppLocalizations.of(context)!.aboutus,style: TextStyle( color: Color(0XFF9C9B9D),fontSize: 15 ),)
                      ],
                    ),
                  ),
                )
                ,
                InkWell(
                  onTap: (){

                    if(Strings.darkmod)
                    {
                      Data_Sever.Save_Data("theme", "false");
                      Strings.darkmod=false;
                    }
                    else
                    {
                      Data_Sever.Save_Data("theme", "true");
                      Strings.darkmod=true;
                    }

                    //Change status bar color
                    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                        statusBarColor: (Strings.darkmod)?Color(0XFF333333):Colors.white,
                        statusBarIconBrightness: (Strings.darkmod)?Brightness.light:Brightness.dark
                    ));

                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 26,right: 26,bottom: 13,top: 13),
                    child: Row(
                      children: [
                        SvgPicture.asset((Strings.darkmod)?"assets/icons/brightness.svg":"assets/icons/eclipse.svg",width: 26,color: Theme.of(context).unselectedWidgetColor)
                        ,
                        Container(
                          margin: EdgeInsets.all(6),
                        )
                        ,
                        Text(AppLocalizations.of(context)!.darkmod,style: TextStyle( color: Color(0XFF9C9B9D),fontSize: 15 ),)
                      ],
                    ),
                  ),
                )
                ,
                Container(
                  height: 1,
                  color: Color(0XFFCCCCCC),
                  margin: EdgeInsets.only(bottom: 20,top:0,left: 20,right: 20),
                )
                ,
                InkWell(
                  onTap: (){

                    //get logout
                    // api_login().Logout(context);

                    //Close app
                    Server().Terminate(context);

                    //Logout
                    // Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> activity_splash_state()), (route) => false);


                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 26,right: 26,bottom: 13,top: 13),
                    child: Row(
                      children: [
                        SvgPicture.asset("assets/icons/exit.svg",width: 26,color: Colors.red)
                        ,
                        Container(
                          margin: EdgeInsets.all(6),
                        )
                        ,
                        Text(AppLocalizations.of(context)!.exit,style: TextStyle( color: Colors.red,fontSize: 15 ),)
                      ],
                    ),
                  ),
                )

                ,
                InkWell(
                  onTap: (){
                    launch("https://izino.ir");
                  },
                  child: Container(
                    margin: EdgeInsets.only(left:36,right: 36,top: 10,bottom: 30),
                    width: MediaQuery.of(context).size.width - 72,
                    height: 108,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(27),
                    ),
                    child: Column(
                      children: [

                        Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Image.asset("assets/icons/izino.png",height: 50),
                        )
                        // ,
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Text(AppLocalizations.of(context)!.devloped_by,style: TextStyle( color: Color(0XFF9C9B9D),fontSize: 12 ),)
                        //     ,
                        //     Text(AppLocalizations.of(context)!.vaya,style: TextStyle( color: Color(0XFFcc4e6d),fontSize: 12 ,fontWeight: FontWeight.bold),)
                        //   ],
                        // )
                        ,
                        Container(
                            child: Text("V "+Strings.AppVersion,style: TextStyle( color: Color(0XFF9C9B9D),fontSize: 8 ),)
                        )

                      ],
                    ),
                  ),
                )


              ],
            ),
          ),
        ),
      ),
    );
  }
  //Main function end


  //Widget logo start
  Widget Logo(BuildContext context)
  {
    return InkWell(
      onTap: (){
        launch("https://izino.ir");
      },
      child: Container(
        margin: EdgeInsets.only(left:36,right: 36,top: 10,bottom: 30),
        width: MediaQuery.of(context).size.width - 72,
        height: 108,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(27),
        ),
        child: Column(
          children: [

            Container(
              margin: EdgeInsets.only(top: 5),
              child: Image.asset("assets/icons/izino.png",height: 50),
            )
            // ,
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text(AppLocalizations.of(context)!.devloped_by,style: TextStyle( color: Color(0XFF9C9B9D),fontSize: 12 ),)
            //     ,
            //     Text(AppLocalizations.of(context)!.vaya,style: TextStyle( color: Color(0XFFcc4e6d),fontSize: 12 ,fontWeight: FontWeight.bold),)
            //   ],
            // )
            ,
            Container(
                child: Text("V "+Strings.AppVersion,style: TextStyle( color: Color(0XFF9C9B9D),fontSize: 8 ),)
            )

          ],
        ),
      ),
    );
  }
  //Widget logo end


  //Change language alert dialog start
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
                      MyApp.language = "en";
                      api_user().SetLanguage(context);
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
                        MyApp.language = "fa";
                        api_user().SetLanguage(context);
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
                        MyApp.language = "tr";
                        api_user().SetLanguage(context);
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Turkish",style: TextStyle( color: Theme.of(context).unselectedWidgetColor , fontSize: 16 ))
                            ,
                            Image.asset("assets/Images/Turk_Flag.png",width: 30,)
                          ],
                        ),
                      )
                  )
                  ,
                  TextButton(
                      onPressed: (){
                        Data_Sever.Save_Data("language", "ar");
                        Strings.language="ar";
                        MyApp.language = "ar";
                        api_user().SetLanguage(context);
                        Navigator.pop(context);
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
                        Data_Sever.Save_Data("language", "fr");
                        Strings.language="fr";
                        MyApp.language = "fr";
                        api_user().SetLanguage(context);
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("French",style: TextStyle( color: Theme.of(context).unselectedWidgetColor , fontSize: 16 ))
                            ,
                            Image.asset("assets/Images/Franc_Flag.png",width: 30,)
                          ],
                        ),
                      )
                  )
                  ,
                  TextButton(
                      onPressed: (){
                        Data_Sever.Save_Data("language", "es");
                        Strings.language="es";
                        MyApp.language = "es";
                        api_user().SetLanguage(context);
                        Navigator.pop(context);
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
                        Data_Sever.Save_Data("language", "ru");
                        Strings.language="ru";
                        MyApp.language = "ru";
                        api_user().SetLanguage(context);
                        Navigator.pop(context);
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
                        Data_Sever.Save_Data("language", "zh");
                        Strings.language="zh";
                        MyApp.language = "zh";
                        api_user().SetLanguage(context);
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Chinese",style: TextStyle( color: Theme.of(context).unselectedWidgetColor , fontSize: 16 ))
                            ,
                            Image.asset("assets/Images/China_Flag.png",width: 30,)
                          ],
                        ),
                      )
                  )
                  ,
                  TextButton(
                      onPressed: (){
                        Data_Sever.Save_Data("language", "it");
                        Strings.language="it";
                        MyApp.language = "it";
                        api_user().SetLanguage(context);
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Italian",style: TextStyle( color: Theme.of(context).unselectedWidgetColor , fontSize: 16 ))
                            ,
                            Image.asset("assets/Images/Italya_Flag.png",width: 30,)
                          ],
                        ),
                      )
                  )
                  ,
                  TextButton(
                      onPressed: (){
                        Data_Sever.Save_Data("language", "de");
                        Strings.language="de";
                        MyApp.language = "de";
                        api_user().SetLanguage(context);
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("German",style: TextStyle( color: Theme.of(context).unselectedWidgetColor , fontSize: 16 ))
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


  //Laws alert dialog start
  Future<void> ShowLawsAlertDialog(BuildContext context) {
    // جدا کردن خطوط
    final List<String> laws = Strings.Config[Strings.language + "_law"]
        .toString()
        .split('\\n');

    return showDialog(
      context: context,
      builder: (ctx) {
        final String title = AppLocalizations.of(context)?.laws ?? 'Laws';

        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).splashColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // عنوان
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).unselectedWidgetColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shrinkWrap: true,
                    itemCount: laws.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          laws[index],
                          style: TextStyle(
                            color: Theme.of(context).unselectedWidgetColor,
                            fontSize: 12,
                            height: 1.6,
                          ),
                          // textAlign: TextAlign.justify,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        AppLocalizations.of(context)?.submit ?? 'Submit',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  //Laws alert dialog end


}