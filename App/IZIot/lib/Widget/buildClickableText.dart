import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Data/Colors/App_Colors.dart';

Widget buildClickableText(BuildContext context, String text) {
  final urlRegex = RegExp(r'(https?://[^\s]+)');

  if (!urlRegex.hasMatch(text)) {

    return Text(
      text,
      style: TextStyle(color: App_Colors.White_Color),
      softWrap: true,
    );
  }

  List<TextSpan> spans = [];
  int lastEnd = 0;

  for (final match in urlRegex.allMatches(text)) {

    if (match.start > lastEnd) {
      spans.add(TextSpan(
        text: text.substring(lastEnd, match.start),
        style: TextStyle(color: App_Colors.White_Color),
      ));
    }

    final url = match.group(0)!;
    spans.add(TextSpan(
      text: url,
      style: TextStyle(
        color: Colors.white,
        // decoration: TextDecoration.underline,
        fontWeight: FontWeight.bold,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () async {
          final uri = Uri.tryParse(url);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('لینک معتبر نیست')),
            );
          }
        },
    ));

    lastEnd = match.end;
  }

  if (lastEnd < text.length) {
    spans.add(TextSpan(
      text: text.substring(lastEnd),
      style: TextStyle(color: App_Colors.White_Color),
    ));
  }

  return Text.rich(
    TextSpan(children: spans),
    softWrap: true,
    textDirection: TextDirection.rtl,
  );
}