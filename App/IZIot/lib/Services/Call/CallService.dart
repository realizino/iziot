import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CallService {
  static Future<void> makePhoneCall(String phoneNumber) async {
    String cleanedNumber = phoneNumber.trim().replaceAll(RegExp(r'\s+'), '');

    if (!cleanedNumber.startsWith('+98') && cleanedNumber.startsWith('09')) {
      cleanedNumber = '+98${cleanedNumber.substring(1)}';
    }
    final Uri telUri = Uri(scheme: 'tel', path: cleanedNumber);

    try {
      // if (await canLaunchUrl(telUri)) {
      //   await launchUrl(telUri);
      // } else {
      //
      // }
      launch(telUri.toString());
    } catch (e) {
    }
  }
}