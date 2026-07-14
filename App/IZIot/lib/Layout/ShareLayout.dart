import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/Screens/User/activity_display.dart';
import 'package:iziot/Screens/activity_qr_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../Server/Server.dart';
import '../Services/NearBy/nearby_share_service.dart';
import '../l10n/app_localizations.dart';

class ShareLayout extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ShareLayoutState();
}

class ShareLayoutState extends State<ShareLayout> {
  bool _nearbyActive = false;

  bool get isRtl {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == "fa" || lang == "ar";
  }

  String get _profileImageUrl => Strings.ProfileImage.isEmpty
      ? Server.Root_Address + "/User/images/user.png"
      : Server.Root_Address + "/File/${Strings.ProfileImage}";

  String get _profileUrl =>
      "https://bzhub.social" + "/User/${Strings.UserData.username}";

  @override
  void dispose() {
    if (_nearbyActive) NearbyShareService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.primaryColor.withOpacity(0.2), width: 3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(_profileImageUrl, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "${Strings.UserData.name} ${Strings.UserData.family}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: theme.unselectedWidgetColor),
                ),
                const SizedBox(height: 4),
                Text("@${Strings.UserData.username}",
                    style: TextStyle(fontSize: 13, color: theme.unselectedWidgetColor)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.primaryColor.withOpacity(0.15), width: 1),
                  ),
                  child: Text(_profileUrl,
                      style: TextStyle(fontSize: 13, color: theme.primaryColor, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!kIsWeb) ...[
                SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: _nearbyActive ? _stopNearby : _startNearby,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _nearbyActive ? Colors.red : const Color(0xFF1C1C1E),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.wifi_tethering_rounded, color: Colors.white, size: 18),
                    label: Text(
                      _nearbyActive
                          ? AppLocalizations.of(context)!.nfc_cancel
                          : AppLocalizations.of(context)!.nfc_share,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () => _showQrDialog(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.primaryColor, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.transparent,
                  ),
                  icon: Icon(Icons.qr_code_rounded, color: theme.primaryColor, size: 18),
                  label: Text(AppLocalizations.of(context)!.qrcode,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.primaryColor)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => Share.share(_profileUrl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
                  label: Text(AppLocalizations.of(context)!.linkshare,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _startNearby() async {
    setState(() => _nearbyActive = true);
    _showNearbyWaitingSheet();

    await NearbyShareService.start(
      myUsername: Strings.UserData.username,
      onReceived: (username) {
        if (!mounted) return;
        _closeSheetAndReset();
        Strings.DeepLink = username;
        Navigator.push(context, MaterialPageRoute(builder: (_) => activity_display()));
      },
      onError: (e) => debugPrint('Nearby share error: $e'),
    );
  }

  Future<void> _stopNearby() async {
    await NearbyShareService.stop();
    _closeSheetAndReset();
  }

  void _closeSheetAndReset() {
    if (Navigator.canPop(context)) Navigator.pop(context);
    setState(() => _nearbyActive = false);
  }

  void _showNearbyWaitingSheet() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isDismissible: false,
      enableDrag: false,
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.85, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              builder: (_, val, child) => Transform.scale(scale: val, child: child),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.wifi_tethering_rounded, color: theme.primaryColor, size: 36),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.nfc_tap_together_title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context)!.nfc_tap_together_desc,
              style: TextStyle(fontSize: 13, color: theme.textTheme.bodySmall?.color, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: _stopNearby,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.dividerColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  AppLocalizations.of(context)!.nfc_cancel,
                  style: TextStyle(fontSize: 14, color: theme.textTheme.bodySmall?.color, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showQrDialog(BuildContext context) {
    final theme = Theme.of(context);
    return showDialog(
      context: context,
      barrierColor: const Color(0x66000000),
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.qrcode,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: QrImageView(
                  data: _profileUrl,
                  version: QrVersions.auto,
                  size: 200,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                  dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                ),
              ),
              const SizedBox(height: 8),
              Text(_profileUrl, style: const TextStyle(fontSize: 11, color: Colors.black), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => activity_qr_scanner()));
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.primaryColor, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: Icon(Icons.qr_code_scanner_rounded, color: theme.primaryColor, size: 18),
                  label: Text(
                    AppLocalizations.of(context)!.openqrcodescanner,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}