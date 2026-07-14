import 'package:iziot/Data/Colors/App_Colors.dart';
import 'package:iziot/Data_Storage/Data_Saver.dart';
import 'package:iziot/Screens/activity_splash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'Data/Strings/Strings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

//Main function start
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (defaultTargetPlatform == TargetPlatform.android) {
    await GoogleSignIn.instance.initialize(
      serverClientId: '250732932207-625mspf9laratikbvf5rr9dlp7pcd7bq.apps.googleusercontent.com',
    );
  }

  runApp(MyApp_state());
}
//Main function end


//state full main starter widget class start
class MyApp_state extends StatefulWidget
{
  @override
  State<StatefulWidget> createState() => MyApp();
}
//state full main starter widget class end


//state main starter widget class start
class MyApp extends State<MyApp_state>
{

  //Global variabls
  bool dark_theme=false;
  static String language="en";
  String token="";


  //Main function start
  @override
  Widget build(BuildContext context)
  {

    //Themplate setup setting start
    Data_Sever.Get_Data("theme").then((value){
      if(value!=null || value!="null" || value!="")
      {
        if(value=="true")
        {
          setState(() {
            dark_theme = true;
          });
        }
        else
        {
          setState(() {
            dark_theme = false;
          });
        }
      }
    });
    Strings.darkmod=dark_theme;
    //Themplate setup setting end


    //Multi language setup start
    Data_Sever.Get_Data("language").then((value){
      if(value!="")
      {
        language=value;
      }
    });
    Strings.language=language;
    //Multi language setup end


    //Get user token start
    Data_Sever.Get_Data("tk").then((value){
      if(value!="")
      {
        token=value;
      }
    });
    Strings.Token=token;
    //Get user token end





    return MaterialApp(
      title: 'IzIot',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(language),

      theme: (!dark_theme)?App_Colors.light:App_Colors.dark,
      // theme: App_Colors.lightTheme,
      // darkTheme: App_Colors.darkTheme,
      // themeMode: dark_theme ? ThemeMode.dark : ThemeMode.light,

      home: activity_splash_state(),
      //initialRoute: '/',
      onGenerateRoute: (setting)
      {
        // List rts=[
        //   '/',
        //   '/Home',
        //   '/Login',
        //   '/Signup',
        //   '/Verify',
        //   '/ForgetPassword',
        //   '/Location',
        //   '/Profile',
        //   '/SignupDone',
        //   '/Start',
        //   '/Update',
        //   '/AccessIsDenied'
        // ];
        //
        // if(!rts.contains(setting.name.toString()))
        // {
        //   Navigator.pushAndRemoveUntil(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context)=>activity_display(username: setting.name.toString(),)
        //     ),
        //     (route) => false
        //   );
        // }
        // else
        // {
        //   switch(setting.name)
        //   {
        //     case '':
        //       Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        //       break;
        //     case 'Home':
        //       Navigator.of(context).pushNamedAndRemoveUntil('/Home', (route) => false);
        //       break;
        //     case 'Login':
        //       Navigator.of(context).pushNamedAndRemoveUntil('/Login', (route) => false);
        //       break;
        //     case 'Signup':
        //       Navigator.of(context).pushNamedAndRemoveUntil('/Signup', (route) => false);
        //       break;
        //     case 'Verify':
        //       Navigator.of(context).pushNamedAndRemoveUntil('/Verify', (route) => false);
        //       break;
        //     case 'ForgetPassword':
        //       Navigator.of(context).pushNamedAndRemoveUntil('/ForgetPassword', (route) => false);
        //       break;
        //     case 'Location':
        //       Navigator.of(context).pushNamedAndRemoveUntil('/Location', (route) => false);
        //       break;
        //     case 'Profile':
        //       Navigator.of(context).pushNamedAndRemoveUntil('/Profile', (route) => false);
        //       break;
        //     case 'SignupDone':
        //       Navigator.of(context).pushNamedAndRemoveUntil('/SignupDone', (route) => false);
        //       break;
        //     case 'AccessIsDenied':
        //       Navigator.of(context).pushNamedAndRemoveUntil('/AccessIsDenied', (route) => false);
        //       break;
        //     case 'Update':
        //       Navigator.of(context).pushNamedAndRemoveUntil('/Update', (route) => false);
        //       break;
        //   }
        // }

        //Set deep link
        Strings.DeepLink=setting.name.toString().replaceFirst("User/", "").replaceFirst("https://bzhub.social/", "").replaceFirst("https://bzhub.ir/", "");

      },
      // routes: {
      //   '/':(context)=>activity_splash_state(),
      //   '/Home':(context)=>activity_home(),
      //   '/Login':(context)=>activity_login(),
      //   '/Signup':(context)=>activity_signup(),
      //   '/Verify':(context)=>activity_verify(),
      //   '/ForgetPassword':(context)=>activity_forgetpassword(),
      //   '/Location':(context)=>activity_newlocation(),
      //   '/Profile':(context)=>activity_profile(),
      //   '/SignupDone':(context)=>activity_signupdone(),
      //   '/Start':(context)=>activity_startslider(),
      //   '/Update':(context)=>activity_update(),
      //   '/AccessIsDenied':(context)=>activity_user_is_access_is_denid(),
      // },
    );
  }
//Main function end

}
//state main starter widget class end