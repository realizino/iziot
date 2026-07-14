import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

bool IOSCheck() {
  if (kIsWeb)
  {
    return defaultTargetPlatform == TargetPlatform.iOS;
  }
  else
  {
    return Platform.isIOS;
  }
}