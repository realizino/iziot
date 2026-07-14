import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/Models/Link/Link_Model.dart';
import 'package:iziot/Widget/GetUserPosition.dart';
import 'package:iziot/api/Links/api_links.dart';
import 'package:iziot/api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Components/ComponentsAds.dart';
import '../Server/Server.dart';
import '../l10n/app_localizations.dart';

class LinksLayout extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LinksLayout_State();
}

class LinksLayout_State extends State<LinksLayout> {
  // ─── State ───────────────────────────────────────────────────────────────────
  final TextEditingController newLinkController = TextEditingController();
  final MapController mapController = MapController();

  late Future<List<Link_Model>> _linksFuture;

  bool submitLoading = false;
  bool removeLoading = false;

  // ─── Helpers ─────────────────────────────────────────────────────────────────
  bool get isRtl {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == "fa" || lang == "ar";
  }

  TextStyle get _btnStyle => TextStyle(
    
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  TextStyle get _linkStyle => TextStyle(
    
    fontSize: 12,
    color: Theme.of(context).textTheme.bodySmall?.color,
  );

  @override
  void initState() {
    super.initState();
    _linksFuture = api_links().GetAllLinks(context);
  }

  Future<void> _refreshLinks() async {
    final future = api_links().GetAllLinks(context);

    setState(() {
      _linksFuture = future;
    });

    await future;
  }

  @override
  void dispose() {
    newLinkController.dispose();
    super.dispose();
  }

  // ─── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        FutureBuilder<List<Link_Model>>(
          future: _linksFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  color: theme.primaryColor,
                  strokeWidth: 2,
                ),
              );
            }

            final links = snapshot.data!;

            if (links.isEmpty) {
              if (Strings.UserData.lat.isNotEmpty &&
                  Strings.UserData.lng.isNotEmpty) {
                return _MapItem(size: "full");
              }
              return _EmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: links.length + 1,
              itemBuilder: (context, index) {
                if (index == links.length) {
                  if (Strings.UserData.lat.isEmpty ||
                      Strings.UserData.lng.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return _MapItem(size: "standard");
                }


                if(Strings.UserData.blue_check == "0") {
                  if (index == 0) {
                    return Column(
                      children: [
                        _LinkItem(
                          model: links[index],
                          index: index,
                          onTap: () => _showContextMenu(context, links[index]),
                        ),
                        Componentsads(),
                      ],
                    );
                  }
                }


                return _LinkItem(
                  model: links[index],
                  index: index,
                  onTap: () => _showContextMenu(context, links[index]),
                );
              },
            );
          },
        ),

        // ─── Add button ────────────────────────────────────────────────────────
        Positioned(
          bottom: 16,
          right: 20,
          child: FloatingActionButton(
            onPressed: () => _showAddLinkDialog(context),
            backgroundColor: theme.primaryColor,
            elevation: 2,
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }

  // ─── Empty state ─────────────────────────────────────────────────────────────
  Widget _EmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/icons/empty.png", width: 160),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.linkrepoisempty,
            style: TextStyle(
              
              fontSize: 13,
              color: theme.unselectedWidgetColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Map item ────────────────────────────────────────────────────────────────
  Widget _MapItem({required String size}) {
    final theme = Theme.of(context);

    final x = Strings.UserData.lat.isNotEmpty
        ? double.parse(Strings.UserData.lat)
        : 0.0;
    final y = Strings.UserData.lng.isNotEmpty
        ? double.parse(Strings.UserData.lng)
        : 0.0;

    final bool isFull = size.toUpperCase() == "FULL";

    // Add extra bottom margin in full mode so the FAB doesn't overlap the map
    final margin = isFull
        ? const EdgeInsets.fromLTRB(
        16, 8, 16, 80) // bottom: 80 leaves room for FAB
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 8);

    return Container(
      margin: margin,
      height: isFull ? 420 : 260,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          mapController: mapController,
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
                  builder: (_) => Icon(
                    Icons.location_pin,
                    color: Theme.of(context).primaryColor,
                    size: 40,
                  ),
                ),
                Marker(
                  point: LatLng(UserPosition.Loc_Lat, UserPosition.Loc_Lng),
                  width: 40,
                  height: 40,
                  builder: (_) => _UserLocationMarker(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _UserLocationMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF4285F4).withOpacity(0.25),
          ),
        ),
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF4285F4),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 4)
            ],
          ),
        ),
      ],
    );
  }

  // ─── Link list item ───────────────────────────────────────────────────────────
  Widget _LinkItem({
    required Link_Model model,
    required int index,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool isPhone = _isNumeric(model.link);
    final bool isTelegram = model.link.contains("t.me");
    final bool isWhatsapp = model.link.contains("wa.me");

    String domainLabel;
    String faviconUrl;

    if (isPhone) {
      domainLabel = AppLocalizations.of(context)!.phone;
      faviconUrl = "";
    } else if (isTelegram) {
      domainLabel = "Telegram";
      faviconUrl =
      "https://www.google.com/s2/favicons?domain=telegram.org&sz=256";
    } else if (isWhatsapp) {
      domainLabel = "WhatsApp";
      faviconUrl =
      "https://www.google.com/s2/favicons?domain=whatsapp.com&sz=256";
    } else {
      final cleanLink = model.link
          .replaceAll("https://", "")
          .replaceAll("http://", "")
          .replaceAll("www.", "");
      domainLabel = _getDomain(model.link);
      faviconUrl =
      "https://www.google.com/s2/favicons?domain=${cleanLink.split('/').first}&sz=256";
    }

    final String displayLink = model.link.endsWith("/")
        ? model.link
        .substring(0, model.link.length - 1)
        .replaceAll("www.", "")
        : model.link.replaceAll("www.", "");

    return Container(
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        top: index == 0 ? 16 : 6,
        bottom: 6,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
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
                      errorBuilder: (_, __, ___) => Icon(Icons.link,
                          color:
                          theme.unselectedWidgetColor,
                          size: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        domainLabel,
                        style: TextStyle(
                          
                          fontSize: 13,
                          color: theme.unselectedWidgetColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayLink,
                        style: TextStyle(
                          
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: theme.unselectedWidgetColor, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Context menu dialog ──────────────────────────────────────────────────────
  Future<void> _showContextMenu(BuildContext context, Link_Model link) async {
    final theme = Theme.of(context);

    return showDialog(
      context: context,
      barrierColor: const Color(0x66000000),
      builder: (_) => Dialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _DialogBtn(
                icon: Icons.open_in_new_rounded,
                label: AppLocalizations.of(context)!.launch,
                color: theme.primaryColor,
                onTap: () async {
                  Navigator.pop(context);
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
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (ctx, setLocal) => _DialogBtn(
                  icon: Icons.delete_outline_rounded,
                  label: AppLocalizations.of(context)!.remove,
                  color: Colors.red,
                  loading: removeLoading,
                  onTap: () async {
                    setLocal(() => removeLoading = true);
                    await api_links()
                        .RemoveLink(context, link.id.toString());
                    _refreshLinks();
                    if (mounted) setState(() => removeLoading = false);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Add link dialog (Final Corrected) ───────────────────────────────────────
  Future<void> _showAddLinkDialog(BuildContext context) async {
    final theme = Theme.of(context);
    newLinkController.clear();

    await showDialog(
      context: context,
      barrierColor: const Color(0x66000000),
      builder: (_) => Dialog(
        backgroundColor: theme.splashColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizations.of(context)!.please_enter_link,
                style: TextStyle(
                  
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: theme.unselectedWidgetColor,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: newLinkController,
                style: TextStyle(
                  
                  fontSize: 14,
                  color: theme.unselectedWidgetColor,
                ),
                keyboardType: TextInputType.url,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: "https://example.com",
                  hintStyle: TextStyle(
                    
                    fontSize: 13,
                    color: theme.unselectedWidgetColor,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 13, horizontal: 16),
                  fillColor: theme.scaffoldBackgroundColor,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: theme.unselectedWidgetColor, width: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              StatefulBuilder(
                builder: (ctx, setLocal) {
                  bool isLoading = false;

                  return SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                        final text = newLinkController.text.trim();

                        final uri = Uri.tryParse(text);
                        final isUrl = uri?.isAbsolute ?? false;
                        final isNumeric = _isNumeric(text);

                        if (isUrl || isNumeric) {
                          setLocal(() => isLoading = true);
                          try {
                            // await api_links().AddNewLink(context, text);
                            //
                            // newLinkController.clear();
                            // Navigator.pop(context);
                            //
                            // Fluttertoast.showToast(
                            //   msg: AppLocalizations.of(context)!.link_added,
                            //   gravity: ToastGravity.BOTTOM,
                            //   toastLength: Toast.LENGTH_SHORT,
                            //   textColor: Colors.white,
                            //   fontSize: 14.0,
                            // );

                            await api_links().AddNewLink(context, text);

                            newLinkController.clear();

                            if (!mounted) return;

                            Navigator.pop(context);

                            await _refreshLinks();

                            Fluttertoast.showToast(
                              msg: AppLocalizations.of(context)!.link_added,
                              gravity: ToastGravity.BOTTOM,
                              toastLength: Toast.LENGTH_SHORT,
                              textColor: Colors.white,
                              fontSize: 14.0,
                            );

                          } catch (e) {
                            Fluttertoast.showToast(
                              msg: AppLocalizations.of(context)!.error_in_link_add,
                              gravity: ToastGravity.BOTTOM,
                              toastLength: Toast.LENGTH_SHORT,
                              textColor: Colors.white,
                              fontSize: 14.0,
                            );
                          } finally {
                            setLocal(() => isLoading = false);
                          }
                        } else {
                          newLinkController.clear();
                          Navigator.pop(context);
                          Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)!
                                .inputisinvalid,
                            gravity: ToastGravity.BOTTOM,
                            toastLength: Toast.LENGTH_SHORT,
                            textColor: Colors.white,
                            fontSize: 14.0,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 1.8),
                      )
                          : Text(
                        AppLocalizations.of(context)!.submit,
                        style: _btnStyle.copyWith(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────
  bool _isNumeric(String text) => double.tryParse(text) != null;

  String _getDomain(String url) {
    try {
      final uri = Uri.parse("https://$url");
      final parts = uri.host.replaceAll("www.", "").split(".");
      return parts.isNotEmpty ? parts[0] : url;
    } catch (_) {
      return url;
    }
  }
}

// ─── Dialog button widget ────────────────────────────────────────────────────
class _DialogBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool loading;

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
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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