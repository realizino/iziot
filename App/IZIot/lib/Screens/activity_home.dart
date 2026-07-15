import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class activity_home extends StatelessWidget
{

  @override
  Widget build(BuildContext context)
  {
    return SafeArea(
        child: Scaffold(
          body: Container(
            child: Center(
              child: Text("Hello world"),
            ),
          ),
        )
    );
  }

}