// Show success snackbar
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void ShowSuccessSnake(BuildContext context,String message)
{
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.right,
        style: TextStyle(fontFamily: 'Vazir'),
      ),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ),
  );
}