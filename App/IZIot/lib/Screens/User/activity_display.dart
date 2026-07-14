import 'package:iziot/Data/Colors/App_Colors.dart';
import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/Models/Link/Link_Model.dart';
import 'package:iziot/Models/User/ReadUser_Model.dart';
import 'package:iziot/Models/User/SaveUser_Model.dart';
import 'package:iziot/Screens/Chat/activity_chat.dart';
import 'package:iziot/Screens/activity_home.dart';
import 'package:iziot/Screens/User/activity_profile.dart';
import 'package:iziot/Widget/GetUserPosition.dart';
import 'package:iziot/Widget/TopBar.dart';
import 'package:iziot/api/Chat/api_chat.dart';
import 'package:iziot/api/Contact/api_contact.dart';
import 'package:iziot/api/Report/api_report.dart';
import 'package:iziot/api/User/api_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../Models/Business/Business_Model.dart';
import '../../Server/Server.dart';
import '../../l10n/app_localizations.dart';
import '../Business/activity_business_display.dart';

class activity_display extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => activity_display_state();
}

class activity_display_state extends State<activity_display> {

  // ─── Theme shortcuts ──────────────────────────────────────────────────────
  Color get _primary  => App_Colors.Theme_Color;
  Color get _bgCard   => Theme.of(context).splashColor;
  Color get _bgPage   => Theme.of(context).scaffoldBackgroundColor;
  Color get _textMain => Theme.of(context).unselectedWidgetColor;
  Color get _textSub  => Theme.of(context).disabledColor;

  // ─── State ────────────────────────────────────────────────────────────────
  final MapController mapController = MapController();
  late final Future<ReadUser_Model> _userData;

  bool displayReportDialog = true;
  bool isSaved    = false;
  bool saveWait   = false;
  bool unsaveWait = false;
  bool ShowFlotActionButton = false;

  String username = "";
  ReadUser_Model? _displayedUser;

  // ─── Helpers ──────────────────────────────────────────────────────────────
  bool get isRtl {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == "fa" || lang == "ar";
  }

  String get _profileImageUrl => Strings.ProfileImage.isEmpty
      ? Server.Root_Address + "/User/images/user.png"
      : Server.Root_Address + "/File/${Strings.ProfileImage}";

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {

    super.initState();
    // Load the target user profile from the API using the deep-link username

    _userData = api_user().GetUser(
        context, Strings.DeepLink.replaceFirst('/', ''));
  }

  // Navigate back to the home screen and clear the navigation stack
  void _goBack() => Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => activity_home()),
          (route) => false);

  // ─── Businesses section ───────────────────────────────────────────────────
  Widget _BusinessesSection(List<Business_Model> businesses) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: _Card(
        borderRadius: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.business,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _textSub,
              ),
            ),
            const SizedBox(height: 12),
            ...businesses.map((bz) => _BusinessItem(bz)).toList(),
          ],
        ),
      ),
    );
  }

  // ─── Single business row inside the businesses card ───────────────────────
  Widget _BusinessItem(Business_Model bz) {
    final imageUrl = bz.image.isEmpty
        ? Server.Root_Address + "/User/images/user.png"
        : bz.image;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => activity_business_display(business: bz),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _bgPage,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 56,
                  height: 56,
                  color: _primary.withOpacity(0.1),
                  child: Icon(Icons.store_rounded, color: _primary, size: 28),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bz.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textMain,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  if (bz.bio.isNotEmpty)
                    Text(
                      bz.bio,
                      style: TextStyle(fontSize: 12, color: _textSub),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 12, color: _textSub),
                      const SizedBox(width: 4),
                      Text(
                        "${bz.open_at} - ${bz.close_at}",
                        style: TextStyle(fontSize: 11, color: _textSub),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: _textSub, size: 20),
          ],
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: SafeArea(
        child: Column(
          children: [
            TopBar(context, true),
            Expanded(
              child: FutureBuilder<ReadUser_Model>(
                future: _userData,
                builder: (context, snapshot) {
                  // Show a loading indicator while the API call is in progress
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                          color: App_Colors.Theme_Color, strokeWidth: 2),
                    );
                  }

                  final data = snapshot.data!;

                  // Cache the loaded user so dialogs can access it later
                  _displayedUser = data;

                  // If the user has no links, show the empty state
                  if (data.username.isEmpty)
                    return _EmptyState();

                  // Sync local state from the freshly loaded API response
                  username = data.username;
                  isSaved  = data.saved;

                  // Parse the comma-separated keywords string into a list
                  final userKeywords = (data.keywords.isNotEmpty)
                      ? data.keywords
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList()
                      : <String>[];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      children: [
                        _ProfileHeader(data),
                        const SizedBox(height: 8),
                        if (userKeywords.isNotEmpty) ...[
                          _KeywordsCard(userKeywords),
                          const SizedBox(height: 8),
                        ],
                        ...data.links.asMap().entries.map(
                              (e) => _LinkItem(model: e.value, index: e.key),
                        ),
                        if (data.businesses.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _BusinessesSection(data.businesses),
                        ],
                        if (data.lat != null &&
                            data.lng != null &&
                            data.lat!.isNotEmpty &&
                            data.lng!.isNotEmpty)
                          _MapItem(lat: data.lat!, lng: data.lng!),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: (_displayedUser != null && _displayedUser!.username.isNotEmpty)
          ? _ActionsFab()
          : null,
    );
  }

  // ─── Profile header (full-width card) ────────────────────────────────────
  Widget _ProfileHeader(ReadUser_Model data) {
    final imageUrl = data.image.isEmpty
        ? Server.Root_Address + "/User/images/user.png"
        : Server.Root_Address + "/File/${data.image}";

    // Use safe fallbacks in case these fields are null
    final community = data.community ?? "";
    final language  = data.language  ?? "";

    // Determine the correct badge asset based on blue_check value
    String? badgeIcon;
    switch (data.blue_check) {
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
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Stack(
        children: [
          // Centered profile image, name, and bio
          Center(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _primary.withOpacity(0.2), width: 3),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(
                          imageUrl,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 90,
                            height: 90,
                            color: _primary.withOpacity(0.1),
                            child: Icon(Icons.person_rounded,
                                color: _primary, size: 40),
                          ),
                        ),
                      ),
                    ),
                    // Show badge overlay if blue_check is non-zero
                    if (data.blue_check != "0")
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Image.asset(badgeIcon!, width: 24, height: 24),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "${data.name} ${data.family}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textMain,
                  ),
                ),
                const SizedBox(height: 4),
                if (data.bio.isNotEmpty)
                  Text(
                    data.bio,
                    style: TextStyle(
                      fontSize: 13,
                      color: _textSub,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Community chip – top-right corner
          if (community.isNotEmpty && community != "null")
            Positioned(
              top: 0,
              right: 0,
              child: _InfoChip(
                icon: Icons.group_rounded,
                label: community,
                backgroundColor: _primary.withOpacity(0.15),
                textColor: _primary,
              ),
            ),

          // Language chip – top-left corner
          if (language.isNotEmpty && language != "null")
            Positioned(
              top: 0,
              left: 0,
              child: _InfoChip(
                icon: Icons.language_rounded,
                label: language,
                backgroundColor: App_Colors.Blue_Color.withOpacity(0.15),
                textColor: App_Colors.Blue_Color,
              ),
            ),
        ],
      ),
    );
  }

  // ─── Small chip for community / language indicators ───────────────────────
  Widget _InfoChip({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Keywords / categories card ───────────────────────────────────────────
  Widget _KeywordsCard(List<String> keywords) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: _Card(
        borderRadius: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.categories,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _textSub,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: keywords
                  .map((kw) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _primary.withOpacity(0.5), width: 1),
                ),
                child: Text(
                  kw,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Link row card ────────────────────────────────────────────────────────
  Widget _LinkItem({required Link_Model model, required int index}) {
    final bool isPhone    = _isNumeric(model.link);
    final bool isTelegram = model.link.contains("t.me");
    final bool isWhatsapp = model.link.contains("wa.me");

    String domainLabel;
    String faviconUrl;

    if (isPhone) {
      domainLabel = AppLocalizations.of(context)!.phone;
      faviconUrl  = "";
    } else if (isTelegram) {
      domainLabel = "Telegram";
      faviconUrl  = "https://www.google.com/s2/favicons?domain=telegram.org&sz=256";
    } else if (isWhatsapp) {
      domainLabel = "WhatsApp";
      faviconUrl  = "https://www.google.com/s2/favicons?domain=whatsapp.com&sz=256";
    } else {
      final clean = model.link
          .replaceAll("https://", "")
          .replaceAll("http://", "")
          .replaceAll("www.", "");
      domainLabel = _getDomain(model.link);
      faviconUrl  = "https://www.google.com/s2/favicons?domain=${clean.split('/').first}&sz=256";
    }

    // Remove trailing slash and strip www for display
    final String displayLink = model.link.endsWith("/")
        ? model.link.substring(0, model.link.length - 1).replaceAll("www.", "")
        : model.link.replaceAll("www.", "");

    return Container(
      margin: EdgeInsets.fromLTRB(16, index == 0 ? 8 : 4, 16, 4),
      child: _Card(
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showLinkMenu(context, model),
          child: Row(
            children: [
              // Favicon / phone icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _bgPage,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: isPhone
                      ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset("assets/icons/phone-call.png",
                        fit: BoxFit.contain),
                  )
                      : Image.network(
                    faviconUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.link, color: _textSub, size: 22),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(domainLabel,
                        style: TextStyle(fontSize: 12, color: _textSub)),
                    const SizedBox(height: 3),
                    Text(
                      displayLink,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: _textSub, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Map card showing the user's pinned location ──────────────────────────
  Widget _MapItem({required String lat, required String lng}) {
    final x = double.tryParse(lat) ?? 0.0;
    final y = double.tryParse(lng) ?? 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      height: 240,
      child: _Card(
        borderRadius: 16,
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(center: LatLng(x, y), zoom: 16.0),
            children: [
              TileLayer(
                urlTemplate: Server.Root_Address+'/tile/proxy.php?layer=standard&z={z}&x={x}&y={y}',
                userAgentPackageName: 'ir.izino.bzhub',
              ),
              MarkerLayer(markers: [
                // Target user's location pin
                Marker(
                  point: LatLng(x, y),
                  width: 50,
                  height: 50,
                  builder: (_) =>
                      Icon(Icons.location_pin, color: _primary, size: 40),
                ),
                // Current device location pin
                Marker(
                  point: LatLng(UserPosition.Loc_Lat, UserPosition.Loc_Lng),
                  width: 40,
                  height: 40,
                  builder: (_) => Icon(Icons.gps_fixed,
                      color: App_Colors.Blue_Color, size: 26),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Empty state (user not found or no links) ─────────────────────────────
  Widget _EmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/icons/empty.png", width: 165),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.usernotfound,
              style: TextStyle(fontSize: 13, color: _textSub),
            ),
          ],
        ),
      ),
    );
  }

  // ─── FAB that opens the options menu ─────────────────────────────────────
  Widget _ActionsFab() {
    return FloatingActionButton(
      onPressed: () => _showOptionsMenu(context),
      backgroundColor: _primary,
      elevation: 2,
      child: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 24),
    );
  }

  // ─── Link action dialog (open / copy) ────────────────────────────────────
  Future<void> _showLinkMenu(BuildContext context, Link_Model link) {
    return showDialog(
      context: context,
      barrierColor: const Color(0x66000000),
      builder: (_) => Dialog(
        backgroundColor: _bgCard,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle indicator
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: _bgPage,
                    borderRadius: BorderRadius.circular(2)),
              ),
              _DialogBtn(
                icon: Icons.open_in_new_rounded,
                label: AppLocalizations.of(context)!.launch,
                color: _primary,
                onTap: () async {
                  Navigator.pop(context);
                  // Prefix phone numbers with tel:, everything else with https://
                  final url = _isNumeric(link.link)
                      ? "tel:${link.link}"
                      : "https://${link.link}";
                  await launch(url);
                },
              ),
              const SizedBox(height: 8),
              _DialogBtn(
                icon: Icons.copy_rounded,
                label: AppLocalizations.of(context)!.copy,
                color: const Color(0xFF3B82F6),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: link.link));
                  Fluttertoast.showToast(
                    msg: AppLocalizations.of(context)!.copylinkinclipboard,
                    gravity: ToastGravity.BOTTOM,
                    toastLength: Toast.LENGTH_SHORT,
                    textColor: Colors.white,
                    fontSize: 14.0,
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Options menu dialog (chat, report, QR, save/unsave) ─────────────────
  Future<void> _showOptionsMenu(BuildContext context) {
    // Snapshot the current user data at dialog-open time so the
    // save/unsave button reflects the correct state immediately.
    final user        = _displayedUser;
    bool localIsSaved = isSaved;

    return showDialog(
      context: context,
      barrierColor: const Color(0x66000000),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => Dialog(
          backgroundColor: _bgCard,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle indicator
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: _bgPage,
                      borderRadius: BorderRadius.circular(2)),
                ),

                // Open chat with this user
                _DialogBtn(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: AppLocalizations.of(context)!.chat,
                  color: const Color(0xFF8B5CF6),
                  onTap: () async {
                    await api_chat().GetChatRoomId(context, username);
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => activity_chat(
                          user_data: SaveUser_Model(
                            id: user!.id,
                            name: user!.name,
                            family: user.family,
                            username: user.username,
                            phone: user.phone,
                            profile_image: user.image,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),

                // Report this user
                _DialogBtn(
                  icon: Icons.flag_outlined,
                  label: AppLocalizations.of(context)!.report,
                  color: const Color(0xFF61a896),
                  onTap: () {
                    Navigator.pop(context);
                    _showReportDialog(context, username);
                  },
                ),
                const SizedBox(height: 8),

                // Show profile QR code
                _DialogBtn(
                  icon: Icons.qr_code_rounded,
                  label: AppLocalizations.of(context)!.qrcode,
                  color: _primary,
                  onTap: () {
                    Navigator.pop(context);
                    _showQrDialog(context);
                  },
                ),
                const SizedBox(height: 8),

                // Save / unsave this profile
                // Uses a local copy of isSaved so the button label and icon
                // update instantly inside the dialog without relying on the
                // outer setState to rebuild first.
                _DialogBtn(
                  icon: localIsSaved
                      ? Icons.bookmark_remove_outlined
                      : Icons.bookmark_add_outlined,
                  label: localIsSaved
                      ? AppLocalizations.of(context)!.unsave
                      : AppLocalizations.of(context)!.save,
                  color: localIsSaved ? Colors.red : _primary,
                  loading: saveWait || unsaveWait,
                  onTap: () async {
                    if (localIsSaved) {
                      // Unsave the profile
                      setLocal(() => unsaveWait = true);
                      await api_contact().GetRemoveSave(context, username);
                      if (mounted) {
                        setState(() {
                          unsaveWait  = false;
                          isSaved     = false;
                          localIsSaved = false;
                        });
                        setLocal(() => localIsSaved = false);
                      }
                    } else {
                      // Save the profile
                      setLocal(() => saveWait = true);
                      await api_contact().AddNewSave(context, username);
                      if (mounted) {
                        setState(() {
                          saveWait    = false;
                          isSaved     = true;
                          localIsSaved = true;
                        });
                        setLocal(() => localIsSaved = true);
                      }
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── QR code dialog ───────────────────────────────────────────────────────
  Future<void> _showQrDialog(BuildContext context) {
    final user       = _displayedUser;
    final profileUrl = "https://bzhub.social" + "/${user!.username}";

    return showDialog(
      context: context,
      barrierColor: const Color(0x66000000),
      builder: (_) => Dialog(
        backgroundColor: _bgCard,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.qrcode,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              // White container so the QR code is always readable
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: QrImageView(
                  data: profileUrl,
                  version: QrVersions.auto,
                  size: 200,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                profileUrl,
                style: const TextStyle(fontSize: 11, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.ok,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Report dialog ────────────────────────────────────────────────────────
  Future<void> _showReportDialog(BuildContext context, String userId) {
    final reports =
    Strings.Config["${Strings.language}_reports"].toString().split(",");

    return showDialog(
      context: context,
      barrierColor: const Color(0x66000000),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => Dialog(
          backgroundColor: _bgCard,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: displayReportDialog
                ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/icons/hate.png", height: 140),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.report,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!
                      .please_select_your_report_topic,
                  style:
                  TextStyle(fontSize: 12, color: _textSub),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Divider(
                    height: 1,
                    color: Theme.of(context).dividerColor),
                // Render one row per report reason
                ...reports.map((r) => Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setLocal(
                              () => displayReportDialog = false);
                      api_report()
                          .AddReport(context, r, userId);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                              Icons.radio_button_unchecked,
                              size: 16,
                              color: _textSub),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(r,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _textMain,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
              ],
            )
            // Confirmation screen shown after a report is submitted
                : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Color(0xFF22C55E), size: 30),
                ),
                const SizedBox(height: 14),
                Text(
                  AppLocalizations.of(context)!
                      .weresivedyourreport,
                  style: TextStyle(
                    fontSize: 14,
                    color: _textSub,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => displayReportDialog = true);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(10)),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.ok,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Utility: check if a string is a phone number (numeric) ──────────────
  bool _isNumeric(String text) => double.tryParse(text) != null;

  // ─── Utility: extract the first subdomain from a URL ─────────────────────
  String _getDomain(String url) {
    try {
      final uri   = Uri.parse("https://$url");
      final parts = uri.host.replaceAll("www.", "").split(".");
      return parts.isNotEmpty ? parts[0] : url;
    } catch (_) {
      return url;
    }
  }

  // ─── Reusable card container ──────────────────────────────────────────────
  Widget _Card({
    required Widget child,
    double borderRadius = 16,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Reusable dialog action button ───────────────────────────────────────────
class _DialogBtn extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final Color        color;
  final VoidCallback onTap;
  final bool         loading;

  const _DialogBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color.withOpacity(0.4),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: loading
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
              color: Colors.white, strokeWidth: 1.8),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}