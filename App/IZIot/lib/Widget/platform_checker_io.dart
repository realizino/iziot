// platform_checker_io.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

enum AppPlatform { android, ios, web }

AppPlatform getCurrentPlatform() {
  if (kIsWeb) return AppPlatform.web;
  if (Platform.isAndroid) return AppPlatform.android;
  if (Platform.isIOS) return AppPlatform.ios;
  return AppPlatform.web; // fallback
}