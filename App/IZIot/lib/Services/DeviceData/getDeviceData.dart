import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<Map<String, String>> getDeviceData() async {
  final deviceInfo = DeviceInfoPlugin();
  final packageInfo = await PackageInfo.fromPlatform();

  String deviceName = '';
  String deviceType = '';
  String osVersion = '';
  String appVersion = packageInfo.version;

  if (kIsWeb) {
    WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
    deviceName = '${webInfo.userAgent ?? 'unknown'}';
    deviceType = 'web';
    osVersion = '${webInfo.appVersion ?? 'unknown'}';
  } else {
    if (Platform.isAndroid) {
      var androidInfo = await deviceInfo.androidInfo;
      deviceName = '${androidInfo.manufacturer} ${androidInfo.model}';
      deviceType = 'android';
      osVersion = 'Android ${androidInfo.version.release}';
    } else if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      deviceName = iosInfo.name ?? iosInfo.model;
      deviceType = 'ios';
      osVersion = '${iosInfo.systemName} ${iosInfo.systemVersion}';
    } else if (Platform.isWindows) {
      var windowsInfo = await deviceInfo.windowsInfo;
      deviceName = windowsInfo.computerName ?? 'unknown';
      deviceType = 'windows';
      osVersion = '${windowsInfo.systemVersion}';
    } else if (Platform.isLinux) {
      var linuxInfo = await deviceInfo.linuxInfo;
      deviceName = linuxInfo.name ?? 'unknown';
      deviceType = 'linux';
      osVersion = linuxInfo.version ?? 'unknown';
    } else if (Platform.isMacOS) {
      var macInfo = await deviceInfo.macOsInfo;
      deviceName = macInfo.computerName ?? 'unknown';
      deviceType = 'macos';
      osVersion = macInfo.osRelease ?? 'unknown';
    } else {
      deviceName = 'unknown';
      deviceType = 'unknown';
      osVersion = 'unknown';
    }
  }

  return {
    'device_name': deviceName,
    'device_type': deviceType,
    'os_version': osVersion,
    'app_version': appVersion,
  };
}

extension on WindowsDeviceInfo
{
  get systemVersion => "Windows";
}