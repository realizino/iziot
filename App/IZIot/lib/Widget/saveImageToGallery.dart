import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart';           // جایگزین اصلی
import 'package:universal_html/html.dart' as html;

import '../Data/Strings/Strings.dart';

Map<String, String> _getAuthHeaders() {
  return {'Authorization': 'Bearer ' + Strings.Token};
}

Future<void> saveImageToGallery(BuildContext context, String url) async {
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Server returned ${response.statusCode}');
    }

    final bytes = response.bodyBytes;

    if (kIsWeb) {
      final blob = html.Blob([bytes], 'image/png');
      final blobUrl = html.Url.createObjectUrlFromBlob(blob);

      html.AnchorElement(href: blobUrl)
        ..setAttribute('download', 'bzhub_image.png')
        ..click();

      html.Url.revokeObjectUrl(blobUrl);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download started'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      await Gal.putImageBytes(
        bytes,
        name: 'bzhub_image_${DateTime.now().millisecondsSinceEpoch}.png', // نام دلخواه
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image saved to gallery'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  } catch (e) {
    debugPrint('Save image error: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not download image'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}