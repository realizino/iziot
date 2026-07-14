import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget RippleBackground(BuildContext context)
{

  return Stack(
    children: [

      Positioned(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(1000)
          ),
        )
      )
      ,
      Positioned(
        left: 35,
        top: 35,
        child: Container(
          width: MediaQuery.of(context).size.width - 70,
          height: MediaQuery.of(context).size.width - 70,
          decoration: BoxDecoration(
              color: Theme.of(context).splashColor,
              borderRadius: BorderRadius.circular(1000)
          ),
        )
      )
      ,
      Positioned(
          left: 75,
          top: 75,
          child: Container(
            width: MediaQuery.of(context).size.width - 150,
            height: MediaQuery.of(context).size.width - 150,
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(1000)
            ),
          )
      )

    ],
  );

}