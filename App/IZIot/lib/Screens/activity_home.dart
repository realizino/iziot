import 'dart:async';

import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/Layout/LinksLayout.dart';
import 'package:iziot/Layout/MyRequestsLayout.dart';
import 'package:iziot/Layout/RequestsLayout.dart';
import 'package:iziot/Layout/ProfileLayout.dart';
import 'package:iziot/Layout/SaveLayout.dart';
import 'package:iziot/Layout/ShareLayout.dart';
import 'package:iziot/Screens/User/activity_profile.dart';
import 'package:iziot/Widget/SideMenu.dart';
import 'package:iziot/api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Data/Colors/App_Colors.dart';
import '../Layout/MapsLayout.dart';
import '../Server/Server.dart';
import '../Widget/IOSCheck.dart';
import '../Widget/TopBar.dart';
import '../l10n/app_localizations.dart';
import 'User/activity_display.dart';

class activity_home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => activity_home_state();
}

class activity_home_state extends State<activity_home> {
  bool notificationsDot = false;

  // ─── State Variables ───────────────────────────────────────────────────────
  bool backPress = false;
  int selectedIndex = 0;
  bool isSideNavCollapsed = false;
  bool sideNavInitialized = false;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // ─── Helpers ───────────────────────────────────────────────────────────────
  bool get isDesktop => MediaQuery.of(context).size.width >= 600;

  bool get isRtl {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == "fa" || lang == "ar";
  }

  List<_NavItem> getNavItems(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final items = [
      _NavItem(
          svgAsset: "assets/main_icons/home-svgrepo-com.svg",
          label: AppLocalizations.of(context)!.home),
      _NavItem(
          svgAsset: "assets/main_icons/streets-map-point-svgrepo-com.svg",
          label: AppLocalizations.of(context)!.maps),
    ];

    if (isDesktop) {
      items.add(_NavItem(
          svgAsset: "assets/main_icons/link-minimalistic-2-svgrepo-com.svg",
          label: AppLocalizations.of(context)!.links));

      items.add(_NavItem(
          svgAsset: "assets/main_icons/box-svgrepo-com.svg",
          label: AppLocalizations.of(context)!.my_requests));
    }

    items.add(_NavItem(
        svgAsset: "assets/main_icons/share-svgrepo-com.svg",
        label: AppLocalizations.of(context)!.share));

    items.add(_NavItem(
        svgAsset: "assets/main_icons/clipboard-list-svgrepo-com.svg",
        label: AppLocalizations.of(context)!.saved));

    items.add(_NavItem(
        isProfile: true,
        label: AppLocalizations.of(context)!.profile));

    return items;
  }

  List<Widget> getLayouts(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final layouts = [
      RequestsLayout(),
      MapsLayout()
    ];

    if (isDesktop) {
      layouts.add(LinksLayout());
      layouts.add(MyRequestsLayout());
    }

    layouts.add(ShareLayout());
    layouts.add(SaveLayout());
    layouts.add(ProfileLayout());

    return layouts;
  }

  String get _profileImageUrl => Strings.ProfileImage.isEmpty
      ? Server.Root_Address+"/User/images/user.png"
      : Server.Root_Address+"/File/${Strings.ProfileImage}";

  // ─── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    if (Strings.UnseenMessagesCount > 0) {
      notificationsDot = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (Strings.DeepLink.isNotEmpty) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => activity_display())
          );
        }

        if(isVersionLower(Strings.AppVersion,Strings.Config["version"].toString())){
          _showUpdateDialog(context);
        }
      } catch (e) {
        print("Update : " + e.toString());
      }
    });
  }

  bool isVersionLower(String? current, String? latest) {
    if (current == null || latest == null) return false;
    List<int> parse(String v) => v.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final curParts = parse(current);
    final latParts = parse(latest);
    for (int i = 0; i < curParts.length || i < latParts.length; i++) {
      final cur = i < curParts.length ? curParts[i] : 0;
      final lat = i < latParts.length ? latParts[i] : 0;
      if (cur < lat) return true;
      if (cur > lat) return false;
    }
    return false;
  }

  void _clearNotificationDot() {
    setState(() => notificationsDot = false);
  }

  // ─── Build Method ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final navItems = getNavItems(context);
    final layouts = getLayouts(context);

    return SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 600;

            if (isWide && !sideNavInitialized) {
              sideNavInitialized = true;
              isSideNavCollapsed = constraints.maxWidth < 900 &&
                  constraints.maxHeight > constraints.maxWidth;
            }

            return isWide
                ? _buildDesktopLayout(navItems, layouts)
                : _buildMobileLayout(navItems, layouts);
          },
        )
    );
  }

  // =============================================
  // ============= Mobile Layout ================
  // =============================================
  Widget _buildMobileLayout(List<_NavItem> navItems, List<Widget> layouts) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        if (!backPress) {
          backPress = true;
          Timer(const Duration(seconds: 2), () => backPress = false);
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.backpressagin,
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_SHORT,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.scaffoldBackgroundColor,
        drawerEdgeDragWidth: 80,
        drawerEnableOpenDragGesture: true,
        drawer: SideMenu(onNotificationTap: _clearNotificationDot),
        bottomNavigationBar: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: _buildBottomNavBar(navItems),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildMobileTopBar(context),
              Expanded(
                child: IndexedStack(
                  index: selectedIndex,
                  children: layouts,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileTopBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.cardColor,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 70,
          child: Stack(
            children: [
              Positioned.fill(child: TopBar(context, false)),

              // Menu Button
              Positioned(
                top: 0,
                bottom: 0,
                left: isRtl ? null : 16,
                right: isRtl ? 16 : null,
                child: InkWell(
                  onTap: () {
                    final state = scaffoldKey.currentState;
                    if (state?.isDrawerOpen ?? false) {
                      state?.closeDrawer();
                    } else {
                      state?.openDrawer();
                    }
                  },
                  child: Icon(Icons.menu, size: 28, color: Theme.of(context).secondaryHeaderColor),
                ),
              ),

              // Notification Dot
              if (notificationsDot)
                Positioned(
                  top: 20,
                  left: isRtl ? null : 40,
                  right: isRtl ? 40 : null,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(List<_NavItem> navItems) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsetsGeometry.only(left: 8,right: 8,bottom: 10,top: 0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => setState(() => selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).splashColor,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).canvasColor,
          selectedFontSize: 11,
          unselectedFontSize: 10,
          showUnselectedLabels: true,
          elevation: 0,
          items: navItems.asMap().entries.map((e) {
            final index = e.key;
            final item = e.value;
            final bool active = selectedIndex == index;

            Widget icon;
            if (item.isProfile) {
              icon = ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  _profileImageUrl,
                  width: 26,
                  height: 26,
                  fit: BoxFit.cover,
                ),
              );
            } else {
              icon = SvgPicture.asset(
                item.svgAsset!,
                width: 22,
                color: active ? theme.primaryColor : Theme.of(context).canvasColor,
              );
            }

            return BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: icon,
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );

  }

  // =============================================
  // ============= Desktop Layout ===============
  // =============================================
  Widget _buildDesktopLayout(List<_NavItem> navItems, List<Widget> layouts) {
    final theme = Theme.of(context);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: SideMenu(onNotificationTap: _clearNotificationDot),
      body: SafeArea(
        child: Row(
          children: [
            _buildDesktopSideNav(navItems),
            Expanded(
              child: Container(
                color: theme.scaffoldBackgroundColor,
                child: Column(
                  children: [
                    _buildDesktopTopBar(navItems),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x08000000),
                                  blurRadius: 20,
                                  offset: Offset(0, -2),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              child: ClipRRect(
                                child: IndexedStack(
                                  index: selectedIndex,
                                  children: layouts,
                                ),
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildDesktopTopBar(List<_NavItem> navItems) {
    final theme = Theme.of(context);

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: theme.scaffoldBackgroundColor,
      child: Row(
        children: [
          // Active Tab Title
          Text(
            navItems[selectedIndex].label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: theme.unselectedWidgetColor,
            ),
          ),

          const Spacer(),

          const SizedBox(width: 14),

          // Profile chip
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => activity_profile())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor, width: 1),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      _profileImageUrl,
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    Strings.UserData.name.isEmpty
                        ? AppLocalizations.of(context)!.profile
                        : "${Strings.UserData.name} ${Strings.UserData.family}",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.unselectedWidgetColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),

          const SizedBox(width: 14),

          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => scaffoldKey.currentState?.openDrawer(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor, width: 1),
              ),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.menu,
                      size: 21, color: theme.unselectedWidgetColor),
                  if (Strings.UnseenMessagesCount != 0)
                    Positioned(
                      top: 8,
                      right: 9,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.cardColor, width: 1.5),
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

  Widget _buildDesktopSideNav(List<_NavItem> navItems) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: isSideNavCollapsed ? 84 : 248,
      color: theme.scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 8, 20),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header Logo
              Container(
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isSideNavCollapsed
                        ? Image.asset("assets/icons/icon.png",
                        key: const ValueKey('collapsed'), height: 32)
                        : Image.asset("assets/icons/r_logo.png",
                        key: const ValueKey('expanded'), height: 40),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  children: [
                    ...navItems.asMap().entries.map((e) {
                      final index = e.key;
                      final item = e.value;
                      final active = selectedIndex == index;

                      return _SideNavItem(
                        item: item,
                        active: active,
                        collapsed: isSideNavCollapsed,
                        profileImageUrl: _profileImageUrl,
                        onTap: () => setState(() => selectedIndex = index),
                      );
                    }),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                child: Divider(height: 1, color: theme.dividerColor),
              ),

              // Collapse toggle
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 14),
                child: _SideNavToggle(
                  collapsed: isSideNavCollapsed,
                  onTap: () =>
                      setState(() => isSideNavCollapsed = !isSideNavCollapsed),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _updateDialogShown = false;
  void _showUpdateDialog(BuildContext context) {
    if (_updateDialogShown) return;
    _updateDialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            actionsAlignment: MainAxisAlignment.center,
            backgroundColor: App_Colors.White_Color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/icons/update.png", width: 150),
                SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.have_new_version+
                      AppLocalizations.of(context)!.have_new_version_continune,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF666666)),
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      launch(Strings.Config["update_link"].toString());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: App_Colors.Theme_Color,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    label: Text(AppLocalizations.of(context)!.update, style: TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    label: Text(AppLocalizations.of(context)!.afew_moment, style: TextStyle(color: Color(0xFF999999), fontSize: 14)),
                  ),
                ],
              ),
            ],
            actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      },
    );
  }
}

// ─── Helper Models & Widgets ─────────────────────────────────────────────────

class _NavItem {
  final String? svgAsset;
  final String label;
  final bool isProfile;

  const _NavItem({
    this.svgAsset,
    required this.label,
    this.isProfile = false,
  });
}

class _SideNavToggle extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onTap;

  const _SideNavToggle({required this.collapsed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment:
          collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            AnimatedRotation(
              turns: collapsed ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.keyboard_double_arrow_left_rounded,
                  size: 18, color: Colors.grey[500]),
            ),
            if (!collapsed) ...[
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.collapse_menu,
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final bool collapsed;
  final String profileImageUrl;
  final VoidCallback onTap;

  const _SideNavItem({
    required this.item,
    required this.active,
    required this.collapsed,
    required this.profileImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: active ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active
              ? [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 10 : 14,
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment:
              collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                item.isProfile
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(profileImageUrl,
                      width: 20, height: 20, fit: BoxFit.cover),
                )
                    : SvgPicture.asset(
                  item.svgAsset!,
                  width: 20,
                  color: active ? Colors.white : Colors.grey[500],
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}