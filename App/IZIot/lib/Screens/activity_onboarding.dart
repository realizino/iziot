import 'package:iziot/Screens/Login/activity_login.dart';
import 'package:iziot/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class activity_onboarding extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => activity_onboarding_state();
}

class activity_onboarding_state extends State<activity_onboarding> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
  }

  Future<void> GetCheckPermissions() async {

    if(!kIsWeb) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.notification_permission_alert_title),
              content: Text(AppLocalizations.of(context)!.notification_permission_alert_text),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await Permission.notification.request();
                  },
                  child: Text("Allow"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: Text("Deny"),
                ),
              ],
            );
          },
        );
      }
    }

    await [
      Permission.location,
      Permission.storage,
      Permission.notification,
    ].request();
  }

  @override
  void initState() {
    super.initState();

    GetCheckPermissions();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: [

                /// Slides
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: PageView(
                      controller: _controller,
                      reverse: true,
                      onPageChanged: (index) {
                        setState(() {
                          isLastPage = index == 3;
                        });
                      },
                      children: [
                        buildPage(
                          image: "assets/Images/onboard1.png",
                          title: AppLocalizations.of(context)!.onboarding1_title,
                          description:AppLocalizations.of(context)!.onboarding1_text,
                        ),
                        buildPage(
                          image: "assets/Images/onboard2.png",
                          title: AppLocalizations.of(context)!.onboarding2_title,
                          description:AppLocalizations.of(context)!.onboarding2_text,
                        ),
                        buildPage(
                          image: "assets/Images/onboard3.png",
                          title: AppLocalizations.of(context)!.onboarding3_title,
                          description:AppLocalizations.of(context)!.onboarding3_text,
                        ),
                        buildPage(
                          image: "assets/Images/onboard4.png",
                          title: AppLocalizations.of(context)!.onboarding4_title,
                          description:AppLocalizations.of(context)!.onboarding4_text,
                        ),
                      ],
                    ),
                  ),
                ),

                /// Indicator
                SmoothPageIndicator(
                  controller: _controller,
                  count: 4,
                  effect: ExpandingDotsEffect(
                    activeDotColor: Color(0xFF61a896),
                    dotColor: Color(0xFFE0E0E0),
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 8,
                  ),
                ),

                SizedBox(height: 30),

                /// Button
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 22),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 50),

                      // Main circular button
                      GestureDetector(
                        onTap: () async {
                          if (isLastPage) {
                            await completeOnboarding();
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> activity_login()),(route)=>false);
                          } else {
                            _controller.nextPage(
                              duration: Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isLastPage
                                  ? [
                                Color(0xFF4CAF50),
                                Color(0xFF66BB6A),
                              ]
                                  : [
                                Color(0xFF61a896),
                                Color(0xFF61a896),
                              ],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isLastPage
                                    ? Color(0xFF4CAF50)
                                    : Color(0xFF61a896))
                                    .withOpacity(0.4),
                                blurRadius: 16,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            isLastPage ? Icons.check : Icons.arrow_forward,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),

                      SizedBox(width: 50),
                    ],
                  ),
                ),

                SizedBox(height: 40),
              ],
            )
        ),
      ),
    );
  }

  Widget buildPage({
    required String image,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Image Container
          SizedBox(
            width: 220,
            height: 220,
            child: Image.asset(
              image,
              width: 280,
              height: 280,
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),

          SizedBox(height: 50),

          /// Title
          Text(
            title,
            textAlign: TextAlign.center,
            textDirection: Directionality.of(context) == TextDirection.rtl? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0XFF333333),
              height: 1.4,
            ),
          ),

          SizedBox(height: 16),

          /// Description
          Text(
            description,
            textAlign: TextAlign.center,
            textDirection: Directionality.of(context) == TextDirection.rtl? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(
              fontSize: 14,
              color: Color(0XFF666666),
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}