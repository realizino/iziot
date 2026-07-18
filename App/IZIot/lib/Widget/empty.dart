import 'package:flutter/cupertino.dart';
import 'package:iziot/l10n/app_localizations.dart';

Widget Empty(BuildContext context){
  
  return Container(
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height - 70,
    child: Center(
      child: SizedBox(
        width: 150,
        height: 220,
        child: Column(
          children: [
            Image.asset("assets/icons/hate.png" , height: 160,)
            ,
            SizedBox(height: 10,)
            ,
            Text(AppLocalizations.of(context)!.listisempty)
          ],
        ),
      ),
    ),
  );
  
}