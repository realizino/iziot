import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../Data/Colors/App_Colors.dart';
import '../Data/Strings/Strings.dart';

class Componentsads extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Strings.Config["sale_background"] == "" ||
        Strings.Config["sale_background"] == "-") {
      return Container();
    } else {
      return Container(
        margin: EdgeInsets.only(left: 20, right: 20, top: 0),
        height: 70,
        width: MediaQuery.of(context).size.width,
        child: SizedBox(
          height: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              // onTap: () {
              //   launch(Strings.Config["ads_link"]);
              // },
              child: CachedNetworkImage(
                imageUrl: Strings.Config["sale_background"],
                height: 100,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                // Loading placeholder
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    color: App_Colors.Theme_Color,
                    strokeWidth: 2,
                  ),
                ),
                // Error placeholder
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
        ),
      );
    }
  }
}