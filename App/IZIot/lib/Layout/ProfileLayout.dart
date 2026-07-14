import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/Screens/Business/activity_business.dart';
import 'package:iziot/Screens/Chat/activity_chats.dart';
import 'package:iziot/Screens/User/activity_profile.dart';
import 'package:iziot/Screens/activity_splash.dart';
import 'package:iziot/Server/Server.dart';
import 'package:iziot/api/Login/api_login.dart';
import 'package:iziot/api/api.dart';
import 'package:iziot/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Data_Storage/Data_Saver.dart';
import '../Screens/User/activity_links.dart';
import '../Screens/Requests/activity_my_requests.dart';
import '../l10n/app_localizations.dart';

class ProfileLayout extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ProfileLayout_State();
}

class ProfileLayout_State extends State<ProfileLayout> {

  bool get isDesktop => MediaQuery.of(context).size.width >= 600;

  static const double _avatarSize = 110;
  static const double _badgeSize  = 30;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String? badgeIcon;
    switch (Strings.UserData.blue_check) {
      case "1":
        badgeIcon = "assets/icons/blue_check.png";
        break;
      case "2":
        badgeIcon = "assets/icons/yellow_check.png";
        break;
      case "3":
        badgeIcon = "assets/icons/orange_check.png";
        break;
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ==================== Profile Header ====================
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 240,
                    child: Stack(
                      children: [
                        // Profile Card
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            margin: const EdgeInsets.only(
                                left: 36, right: 36, bottom: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(27),
                              color: theme.cardColor,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 70),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 25, right: 25, bottom: 25),
                                  child: Column(
                                    children: [
                                      Text(
                                        "${Strings.UserData.name} ${Strings.UserData.family}",
                                        style: TextStyle(
                                          color: theme.unselectedWidgetColor,
                                          fontSize: 18,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        Strings.UserData.bio.isEmpty
                                            ? ""
                                            : Strings.UserData.bio,
                                        style: TextStyle(
                                          color: theme.unselectedWidgetColor,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Avatar + Verified Badge (anchored together, no screen-width math)
                        Positioned(
                          top: 20,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: SizedBox(
                              width: _avatarSize,
                              height: _avatarSize,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.network(
                                      Strings.ProfileImage.isEmpty
                                          ? Server.Root_Address+"/User/images/user.png"
                                          : Server.Root_Address+"/File/${Strings.ProfileImage}",
                                      width: _avatarSize,
                                      height: _avatarSize,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          SvgPicture.asset(
                                            "assets/main_icons/user.png",
                                            width: _avatarSize,
                                            height: _avatarSize,
                                            fit: BoxFit.cover,
                                          ),
                                    ),
                                  ),

                                  if (Strings.UserData.blue_check != "0")
                                    Positioned(
                                      bottom: -2,
                                      right: -2,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: theme.scaffoldBackgroundColor,
                                        ),
                                        child: Image.asset(
                                          badgeIcon!,
                                          width: _badgeSize,
                                          height: _badgeSize,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==================== Menu Items ====================
                  Container(
                    margin: const EdgeInsets.only(
                        left: 36, right: 36, top: 10, bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(27),
                      color: theme.cardColor,
                    ),
                    child: Column(
                      children: [
                        _menuItem(
                          context,
                          icon: SvgPicture.asset(
                            "assets/main_icons/user-rounded-svgrepo-com.svg",
                            width: 26,
                            color: theme.unselectedWidgetColor,
                          ),
                          title: AppLocalizations.of(context)!.profile,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => activity_profile()),
                          ),
                        ),
                        (!isDesktop)?_menuItem(
                          context,
                          icon: SvgPicture.asset(
                            "assets/main_icons/link-minimalistic-2-svgrepo-com.svg",
                            width: 26,
                            color: theme.unselectedWidgetColor,
                          ),
                          title: AppLocalizations.of(context)!.links,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => activity_links()),
                          ),
                        ):Container(),
                        (!isDesktop)?_menuItem(
                          context,
                          icon: SvgPicture.asset(
                            "assets/main_icons/box-svgrepo-com.svg",
                            width: 26,
                            color: theme.unselectedWidgetColor,
                          ),
                          title: AppLocalizations.of(context)!.my_requests,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => activity_my_requests()),
                          ),
                        ):Container(),
                        _menuItem(
                          context,
                          icon: SvgPicture.asset(
                            "assets/main_icons/shop-2-svgrepo-com.svg",
                            width: 26,
                            color: theme.unselectedWidgetColor,
                          ),
                          title: AppLocalizations.of(context)!.business,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => activity_business()),
                          ),
                        ),
                        _menuItem(
                          context,
                          icon: SvgPicture.asset(
                            "assets/main_icons/chat-round-dots-svgrepo-com.svg",
                            width: 26,
                            color: theme.unselectedWidgetColor,
                          ),
                          title: AppLocalizations.of(context)!.chat,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => activity_chats()),
                          ),
                        ),
                        _menuItem(
                          context,
                          icon: SvgPicture.asset(
                            "assets/main_icons/laptop-minimalistic-svgrepo-com.svg",
                            width: 26,
                            color: theme.unselectedWidgetColor,
                          ),
                          title: AppLocalizations.of(context)!.aboutus,
                          onTap: () => launch("https://izino.ir"),
                        ),
                        _menuItem(
                          context,
                          icon: SvgPicture.asset(
                            Strings.darkmod
                                ? "assets/main_icons/sun-2-svgrepo-com.svg"
                                : "assets/main_icons/moon-svgrepo-com.svg",
                            width: 26,
                            color: theme.unselectedWidgetColor,
                          ),
                          title: AppLocalizations.of(context)!.darkmod,
                          onTap: () {
                            setState(() {
                              Strings.darkmod = !Strings.darkmod;
                              Data_Sever.Save_Data(
                                  "theme", Strings.darkmod ? "true" : "false");
                            });

                            SystemChrome.setSystemUIOverlayStyle(
                              SystemUiOverlayStyle(
                                statusBarColor: Strings.darkmod
                                    ? const Color(0XFF333333)
                                    : Colors.white,
                                statusBarIconBrightness: Strings.darkmod
                                    ? Brightness.light
                                    : Brightness.dark,
                              ),
                            );
                          },
                        ),
                        _menuItem(
                          context,
                          icon: SvgPicture.asset(
                            "assets/main_icons/exit-svgrepo-com.svg",
                            width: 26,
                            color: Colors.red,
                          ),
                          title: AppLocalizations.of(context)!.exit,
                          onTap: () {

                            // api_login().Logout(context);
                            // Server().Terminate(context);
                            // Navigator.pushAndRemoveUntil(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => activity_splash_state()),
                            //       (route) => false,
                            // );

                            //get logout
                            // api_login().Logout(context);

                            //Close app
                            Server().Terminate(context);

                            //Logout
                            // Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> activity_splash_state()), (route) => false);




                          },
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  // ==================== Footer (Version) ====================
                  InkWell(
                    onTap: () => launch("https://izino.ir"),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(
                          left: 36, right: 36, top: 10, bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(27),
                        color: theme.cardColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            Image.asset("assets/icons/izino.png", height: 48),
                            const SizedBox(height: 8),
                            Text(
                              "V ${Strings.AppVersion}",
                              style: TextStyle(
                                color: theme.unselectedWidgetColor,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Menu Item Widget ====================
  Widget _menuItem(
      BuildContext context, {
        required Widget icon,
        required String title,
        required VoidCallback onTap,
        bool isLast = false,
      }) {
    final theme = Theme.of(context);
    final isExit = title == AppLocalizations.of(context)!.exit;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(
          left: 26,
          right: 26,
          top: 14,
          bottom: isLast ? 20 : 14,
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isExit ? Colors.red : theme.unselectedWidgetColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}