import 'package:iziot/main.dart';
import 'package:flutter/material.dart';

class App_Colors
{

  static String Black_Color="#000000DD";
  static String Green_String_Color="#64dd17";
  static String Red_String_Color="#FF0000";

  static Color Theme_Color=Oragne_Color;

  static Color White_Color=Colors.white;
  static Color Blue_Color=Colors.blue;
  static Color Oragne_Color=Color(0XFFd7561c);

  static Color Green_Color=Color(0XFFAED581);
  static Color Red_Color=Color(0XFFD32F2F);

  static Color Deep_Red_Color=Color(0xFFFF1A1A);
  static Color Gray_Color=Color(0XFFCCCCCC);
  static Color Black_Gray_Color=Color(0XFF6666666);
  static Color Line_Border_Color=Color(0XFFF9F9F9);
  static Color Oval_Background_Color=Color(0xFF6E6767);
  static Color Elements_Backcolor=Colors.black87;
  static Color Dark_Backcolor=Color(0XFF222222);
  static Color Text1_Color=Colors.black87;
  static Color Text2_Color=Color(0XFFCCCCCC);
  static Color Unknow_Color=Color(0XFF505050);
  static Color Divider_Color=Color(0xFFC2BFBF);
  static Color History_Background=Color(0xFFffc928);
  static Color Transparent_Color=Colors.transparent;

  static ThemeData light=ThemeData(
    useMaterial3: true,
      // colorScheme: ColorScheme(
      //     brightness: Brightness.light,
      //     primary: Theme_Color,
      //     onPrimary: Theme_Color,
      //     secondary: Theme_Color,
      //     onSecondary: Theme_Color,
      //     error: Red_Color,
      //     onError: Red_Color,
      //     surface: Colors.transparent,
      //     onSurface: Colors.transparent
      // ),
    scaffoldBackgroundColor: Color(0XFFEEEEEE),
    primaryColor: Color(0XFFd7561c),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: Theme_Color,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Theme_Color,
      foregroundColor: Colors.white,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return Color(0XFFd7561c);
        }
        return Colors.white;
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme_Color,
        foregroundColor: Colors.white,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme_Color,
        side: BorderSide(color: Theme_Color),
      ),
    ),
    primarySwatch: Colors.orange,
    splashColor: Colors.white,
    cardColor: Colors.white,
    canvasColor: Color(0XFF999999),
    dividerColor:Color(0XFFCCCCCC),
    unselectedWidgetColor: Color(0XFF666666),
    disabledColor: Color(0XFF707070),
    secondaryHeaderColor: Colors.black45,
    fontFamily: (MyApp.language == "fa" || MyApp.language == "ar")?'Vazir':'Noto'
    // fontFamily: 'Vazir',
  );

  static ThemeData dark=ThemeData(
    useMaterial3: true,
    // colorScheme: ColorScheme(
    //     brightness: Brightness.dark,
    //     primary: Theme_Color,
    //     onPrimary: Theme_Color,
    //     secondary: Theme_Color,
    //     onSecondary: Theme_Color,
    //     error: Red_Color,
    //     onError: Red_Color,
    //     surface: Colors.transparent,
    //     onSurface: Colors.transparent
    // ),
    scaffoldBackgroundColor: Color(0XFF555555),
    primaryColor: Color(0XFFd7561c),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: Theme_Color,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Theme_Color,
      foregroundColor: Colors.white,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return Color(0XFFd7561c);
        }
        return Colors.white;
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme_Color,
        foregroundColor: Colors.white,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme_Color,
        side: BorderSide(color: Theme_Color),
      ),
    ),
    primarySwatch: Colors.orange,
    splashColor: Color(0XFF333333),
    cardColor: Color(0XFF333333),
    canvasColor: Color(0XFF999999),
    dividerColor:Color(0XFFAAAAAA),
    unselectedWidgetColor: Colors.white,
    disabledColor: Colors.white,
    secondaryHeaderColor: Colors.white60,
    fontFamily: (MyApp.language == "fa" || MyApp.language == "ar")?'Vazir':'Noto'
    // fontFamily: 'Vazir',
  );

  
  static String get appFontFamily {
    return (MyApp.language == "fa" || MyApp.language == "ar") ? "Vazir" : "Noto";
  }

}