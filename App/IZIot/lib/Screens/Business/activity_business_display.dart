import 'package:iziot/Data/Colors/App_Colors.dart';
import 'package:iziot/Models/Business/Business_Model.dart';
import 'package:iziot/Widget/TopBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../Data/Strings/Strings.dart';
import '../../Models/Link/BLink_Model.dart';
import '../../Server/Server.dart';
import '../../Widget/GetUserPosition.dart';
import '../../api/BusinessLinks/api_business_links.dart';
import '../../l10n/app_localizations.dart';
import '../User/activity_display.dart';

class activity_business_display extends StatefulWidget {
  final Business_Model business;

  const activity_business_display({
    super.key,
    required this.business,
  });

  @override
  State<activity_business_display> createState() => _ActivityBusinessDisplayState();
}

class _ActivityBusinessDisplayState extends State<activity_business_display> {
  Color get _primary => App_Colors.Theme_Color;
  Color get _bgCard => Theme.of(context).splashColor;
  Color get _bgPage => Theme.of(context).scaffoldBackgroundColor;
  Color get _textMain => Theme.of(context).unselectedWidgetColor;
  Color get _textSub => Theme.of(context).disabledColor;

  final MapController _mapController = MapController();

  bool get isRtl {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == "fa" || lang == "ar";
  }

  List<BLink_Model> _links = [];
  bool _linksLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    try {
      final links = await api_business_links().GetBusinessLinks(
        context,
        business_id: widget.business.id,
      );
      if (mounted) {
        setState(() {
          _links = links;
          _linksLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _linksLoading = false);
    }
  }

  // ====================== Badge Helper ======================
  String? _badgeIcon(String blueCheck) {
    switch (blueCheck) {
      case "1":
        return "assets/icons/blue_check.png";
      case "2":
        return "assets/icons/yellow_check.png";
      case "3":
        return "assets/icons/orange_check.png";
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bz = widget.business;

    final imageUrl = bz.image.isEmpty
        ? Server.Root_Address+"/User/images/user.png"
        : bz.image;

    final String badgeIcon = _badgeIcon(bz.check_type) ?? "";

    return SafeArea(
        child: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: _bgPage,
            body: SafeArea(
              child: Column(
                children: [
                  TopBar(context, true),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Column(
                        children: [
                          // Cover Image
                          Container(
                            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            height: 200,
                            child: _Card(
                              borderRadius: 16,
                              padding: EdgeInsets.zero,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: _primary.withOpacity(0.1),
                                    child: Icon(Icons.store_rounded, color: _primary, size: 60),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Info Card
                          Container(
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: _Card(
                              borderRadius: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          bz.name,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: _textMain,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (bz.check_type != "0" && badgeIcon.isNotEmpty) ...[
                                        const SizedBox(width: 6),
                                        Image.asset(badgeIcon, width: 20, height: 20),
                                      ],
                                    ],
                                  ),
                                  if (bz.bio.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      bz.bio,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _textSub,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  Divider(height: 1, color: Theme.of(context).dividerColor),
                                  const SizedBox(height: 16),

                                  if (bz.username.isNotEmpty) ...[
                                    _InfoRow(
                                      icon: Icons.person_rounded,
                                      label: bz.username,
                                      onTap: () {
                                        Strings.DeepLink = "/${bz.username}";
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => activity_display()),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                  ],

                                  _InfoRow(
                                    icon: Icons.access_time_rounded,
                                    label: "${bz.open_at} - ${bz.close_at}",
                                  ),

                                  if (bz.phone.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    _InfoRow(
                                      icon: Icons.phone_rounded,
                                      label: bz.phone,
                                      onTap: () => launchUrl(Uri.parse("tel:${bz.phone}")),
                                    ),
                                  ],

                                  if (bz.address.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    _InfoRow(
                                      icon: Icons.location_on_rounded,
                                      label: bz.address,
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(text: bz.address));
                                        Fluttertoast.showToast(
                                          msg: AppLocalizations.of(context)!.copylinkinclipboard,
                                          gravity: ToastGravity.BOTTOM,
                                          toastLength: Toast.LENGTH_SHORT,
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          // Links Section
                          if (_linksLoading)
                            Container(
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: _Card(
                                borderRadius: 16,
                                child: const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              ),
                            )
                          else if (_links.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: _Card(
                                borderRadius: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.linkshare,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: _textSub,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ..._links.map((link) => _LinkItem(link)),
                                  ],
                                ),
                              ),
                            ),

                          // Map
                          if (bz.lat.isNotEmpty && bz.lng.isNotEmpty)
                            _MapItem(lat: bz.lat, lng: bz.lng),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }

  // ====================== Link Item ======================
  Widget _LinkItem(BLink_Model model) {
    final bool isPhone = double.tryParse(model.link) != null;
    final bool isTelegram = model.link.contains("t.me");
    final bool isWhatsapp = model.link.contains("wa.me");

    // Clean the link: strip any protocol variant (https://, http://, https//, http//)
    // and any leading "www." — this handles malformed links missing the colon too.
    String cleanLink = model.link.trim();
    cleanLink = cleanLink.replaceAll(RegExp(r'^https?:?/{1,2}'), '');
    cleanLink = cleanLink.replaceAll(RegExp(r'^www\.'), '');

    String domainLabel;
    String faviconUrl;

    if (isPhone) {
      domainLabel = AppLocalizations.of(context)!.phone;
      faviconUrl = "";
    } else if (isTelegram) {
      domainLabel = "Telegram";
      faviconUrl = "https://www.google.com/s2/favicons?domain=telegram.org&sz=256";
    } else if (isWhatsapp) {
      domainLabel = "WhatsApp";
      faviconUrl = "https://www.google.com/s2/favicons?domain=whatsapp.com&sz=256";
    } else {
      domainLabel = cleanLink.split('/').first.split('.').first;
      faviconUrl = "https://www.google.com/s2/favicons?domain=${cleanLink.split('/').first}&sz=256";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _bgPage,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final url = isPhone ? "tel:${model.link}" : "https://$cleanLink";
          try {
            final uri = Uri.parse(url);
            final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
            if (!launched && mounted) {
              Fluttertoast.showToast(
                msg: "Unable to open this link",
                gravity: ToastGravity.BOTTOM,
                toastLength: Toast.LENGTH_SHORT,
              );
            }
          } catch (e) {
            if (mounted) {
              Fluttertoast.showToast(
                msg: "Invalid link",
                gravity: ToastGravity.BOTTOM,
                toastLength: Toast.LENGTH_SHORT,
              );
            }
          }
        },
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _bgCard,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: isPhone
                    ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset("assets/icons/phone-call.png", fit: BoxFit.contain),
                )
                    : Image.network(
                  faviconUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.link, color: _textSub, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    domainLabel,
                    style: TextStyle(fontSize: 11, color: _textSub),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cleanLink,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: _textSub, size: 18),
          ],
        ),
      ),
    );
  }

  // ====================== Info Row ======================
  Widget _InfoRow({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: _primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: _textMain),
            ),
          ),
          if (onTap != null)
            Icon(Icons.chevron_right_rounded, size: 18, color: _textSub),
        ],
      ),
    );
  }

  // ====================== Map Widget ======================
  Widget _MapItem({required String lat, required String lng}) {
    final double x = double.tryParse(lat) ?? 0.0;
    final double y = double.tryParse(lng) ?? 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      height: 240,
      child: _Card(
        borderRadius: 16,
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(x, y),
              zoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: Server.Root_Address+'/tile/proxy.php?layer=standard&z={z}&x={x}&y={y}',
                userAgentPackageName: 'ir.izino.bzhub',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(x, y),
                    width: 50,
                    height: 50,
                    builder: (_) =>
                        Icon(Icons.location_pin, color: _primary, size: 40),
                  ),
                  Marker(
                    point: LatLng(UserPosition.Loc_Lat, UserPosition.Loc_Lng),
                    width: 40,
                    height: 40,
                    builder: (_) => Icon(Icons.gps_fixed,
                        color: App_Colors.Blue_Color, size: 26),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====================== Card Widget ======================
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