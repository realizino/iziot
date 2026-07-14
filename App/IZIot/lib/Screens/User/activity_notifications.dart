import 'package:iziot/Data/Colors/App_Colors.dart';
import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/Models/Notification/Notification_Model.dart';
import 'package:iziot/Screens/activity_home.dart';
import 'package:iziot/Screens/User/activity_profile.dart';
import 'package:iziot/Widget/TopBar.dart';
import 'package:iziot/api/User/api_user.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Server/Server.dart';
import '../../l10n/app_localizations.dart';

class activity_notifications_state extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => activity_notifications();
}

class activity_notifications extends State<activity_notifications_state> {
  DateTime now = DateTime.now();
  late Gregorian g1;
  late Jalali j1;

  @override
  void initState() {
    super.initState();

    // Mark all notifications as seen on the server
    api_user().SeenNotifications(context);
  }

  @override
  Widget build(BuildContext context) {
    // Reset the unread badge counter
    Strings.UnseenMessagesCount = 0;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            TopBar(context, true),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 7, bottom: 7),
                child: _buildNotificationList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Notification list (uses Strings.Messages directly) ─────────────
  Widget _buildNotificationList() {
    if (Strings.Messages.isEmpty) {
      return Center(
        child: SizedBox(
          height: 180,
          width: 250,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/icons/empty.png",
                height: 160,
                width: 250,               // اضافه‌شده
                fit: BoxFit.contain,      // اصلاحی
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.nothavemessageyet,
                style: TextStyle(
                  color: Theme.of(context).unselectedWidgetColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: Strings.Messages.length,
      itemBuilder: (context, index) {
        final item = Strings.Messages[index];

        // Convert Gregorian date to Jalali
        if (item.date.isEmpty) {
          g1 = Gregorian(now.year, now.month, now.day);
        } else {
          final dateStr = item.date.split(' ')[0];
          final parts = dateStr.split('-');
          g1 = Gregorian(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
        j1 = g1.toJalali();

        final isRtl = Strings.language == "fa" || Strings.language == "ar";

        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: Material(
              color: Theme.of(context).splashColor,
              elevation: 0,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  if (item.link.isNotEmpty || item.link != "-") {
                    launch(item.link);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      FractionallySizedBox(
                        widthFactor: 1,
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).unselectedWidgetColor,
                          ),
                          textAlign:
                          isRtl ? TextAlign.right : TextAlign.left,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Content
                      FractionallySizedBox(
                        widthFactor: 1,
                        child: Text(
                          item.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).unselectedWidgetColor,
                          ),
                          textAlign:
                          isRtl ? TextAlign.right : TextAlign.left,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Date (Jalali)
                      FractionallySizedBox(
                        widthFactor: 1,
                        child: Text(
                          "${j1.year}/${j1.month}/${j1.day}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).unselectedWidgetColor,
                          ),
                          textAlign:
                          isRtl ? TextAlign.left : TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Custom top bar (unchanged) ─────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    final isRtl = Strings.language == "fa" || Strings.language == "ar";

    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          InkWell(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => activity_home()),
                    (route) => false,
              );
            },
            child: SizedBox(
              width: 35,
              child: Icon(
                isRtl
                    ? Icons.keyboard_arrow_right
                    : Icons.keyboard_arrow_left,
                color: Theme.of(context).disabledColor,
                size: 25,
              ),
            ),
          ),
          // App icon
          InkWell(
            child: Image.asset("assets/icons/icon.png", height: 45),
          ),
          // Profile picture
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => activity_profile()),
              );
            },
            child: SizedBox(
              width: 35,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  Strings.ProfileImage.isEmpty
                      ? Server.Root_Address+"/User/images/user.png"
                      : Server.Root_Address+"/File/${Strings.ProfileImage}",
                  width: 35,
                  height: 35,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}