import 'package:flutter/cupertino.dart';

String MoneyFormat(double value) {
  return value.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ',',
  );
}


String MoneyFormatS(String value) {
  return value.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ',',
  );
}
