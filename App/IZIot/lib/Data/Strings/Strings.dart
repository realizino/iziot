import 'package:iziot/Models/Notification/Notification_Model.dart';
import 'package:iziot/Models/User/User_Model.dart';

class Strings
{

  static String AppVersion="1.1";
  static bool darkmod=false;
  static String language="en";
  static String Token="";
  static String DeviceToken="";

  static List<Notification_Model> Messages=[];

  static var Config={};

  static String UT_Token="";

  static late User_Model UserData;
  static String ProfileImage="";
  static int UnseenMessagesCount=0;

  static String DeepLink="";

  static String Chat_Id="";
  static const Map<String, String> _langToCurrency = {
    'fa': 'IRR',   // فارسی → ریال
    'tr': 'TRY',   // ترکی → لیر
    'ar': 'SAR',   // عربی → ریال سعودی (می‌توانید AED یا EGP بگذارید)
    'ru': 'RUB',   // روسی → روبل
    'zh': 'CNY',   // چینی → یوان
    'es': 'EUR',   // اسپانیایی → یورو
    'fr': 'EUR',   // فرانسوی → یورو
    'de': 'EUR',   // آلمانی → یورو
    'it': 'EUR',   // ایتالیایی → یورو
    'en': 'USD',   // انگلیسی → دلار
  };

  static String currencyForLanguage(String? lang) {
    if (lang == null) return 'USD';
    return _langToCurrency[lang] ?? 'USD';
  }

}