import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/Screens/activity_home.dart';
import 'package:iziot/Screens/User/activity_profile.dart';
import 'package:iziot/Widget/GetUserPosition.dart';
import 'package:iziot/api/Links/api_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:iziot/l10n/app_localizations.dart';

import '../../Server/Server.dart';
import '../../Widget/TopBar.dart';

class activity_newlocation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => activity_newlocation_State();
}

class activity_newlocation_State extends State<activity_newlocation> {
  final MAP = MapController();
  final double Zoom = 16.0;
  bool _isSubmitting = false;
  bool _isRemoveMode = false;

  bool get hasLocation =>
      Strings.UserData.lat.isNotEmpty && Strings.UserData.lng.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _isRemoveMode = hasLocation;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            children: [
              TopBar(context, true),
              Expanded(child: _MapArea(context)),
              _BottomPanel(context),
            ],
          ),
        ),
      ),
    );
  }

  // ====================== Map Area ======================
  Widget _MapArea(BuildContext context) {
    // Decide initial center: saved location if available, else current GPS
    final LatLng initialCenter = hasLocation
        ? LatLng(double.parse(Strings.UserData.lat), double.parse(Strings.UserData.lng))
        : LatLng(UserPosition.Loc_Lat, UserPosition.Loc_Lng);

    return Stack(
      children: [
        // Flutter Map
        FlutterMap(
          mapController: MAP,
          options: MapOptions(
            center: initialCenter,
            zoom: Zoom,
          ),
          children: [
            TileLayer(
              urlTemplate: Server.Root_Address+'/tile/proxy.php?layer=standard&z={z}&x={x}&y={y}',
              userAgentPackageName: 'ir.izino.bzhub',
            ),
            MarkerLayer(
              markers: [
                // GPS marker (current device location)
                Marker(
                  point: LatLng(UserPosition.Loc_Lat, UserPosition.Loc_Lng),
                  width: 22,
                  height: 22,
                  builder: (_) => Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2196F3).withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),

                // Saved location marker (shown only if a location is already stored)
                if (hasLocation)
                  Marker(
                    point: LatLng(
                      double.parse(Strings.UserData.lat),
                      double.parse(Strings.UserData.lng),
                    ),
                    width: 30,
                    height: 30,
                    builder: (_) => const Icon(
                      Icons.location_on,
                      color: Colors.deepOrange,
                      size: 30,
                    ),
                  ),
              ],
            ),
          ],
        ),

        // Center pin (only when not in remove mode)
        if (!_isRemoveMode)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 22,right: 25),
              child: _CenterPin(),
            ),
          ),

        // Location info card (top overlay) – can be enabled if needed
        // Positioned(
        //   top: 14,
        //   left: 16,
        //   right: 16,
        //   child: _LocationInfoCard(context),
        // ),

        // Zoom controls
        Positioned(
          left: 14,
          bottom: 14,
          child: _ZoomControls(),
        ),
      ],
    );
  }

  // ====================== Location Info Card ======================
  Widget _LocationInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.5),
      ),
      child: Row(
        children: [
          // Pulsing dot
          _PulsingDot(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.currentlocation,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
                Text(
                  "${UserPosition.Loc_Lat.toStringAsFixed(4)}°, ${UserPosition.Loc_Lng.toStringAsFixed(4)}°",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.my_location_rounded,
              size: 18, color: Theme.of(context).primaryColor),
        ],
      ),
    );
  }

  // ====================== Zoom Controls ======================
  Widget _ZoomControls() {
    return Column(
      children: [
        _mapCtrlBtn(icon: Icons.add, onTap: () {
          MAP.move(MAP.center, MAP.zoom + 1);
        }),
        const SizedBox(height: 6),
        _mapCtrlBtn(icon: Icons.remove, onTap: () {
          MAP.move(MAP.center, MAP.zoom - 1);
        }),
      ],
    );
  }

  Widget _mapCtrlBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.5),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF444444)),
      ),
    );
  }

  // ====================== Bottom Panel ======================
  Widget _BottomPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).splashColor,
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.06), width: 0.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mode Toggle
          _ModeToggle(context),
          const SizedBox(height: 14),

          // Submit Button
          _SubmitButton(context),
        ],
      ),
    );
  }

  // ====================== Mode Toggle ======================
  Widget _ModeToggle(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: [
          _modeToggleBtn(
            label: AppLocalizations.of(context)!.nnew,
            icon: Icons.location_on_rounded,
            active: !_isRemoveMode,
            onTap: () => setState(() => _isRemoveMode = false),
          ),
          const SizedBox(width: 10),
          _modeToggleBtn(
            label: AppLocalizations.of(context)!.remove,
            icon: Icons.delete_outline_rounded,
            active: _isRemoveMode,
            onTap: hasLocation ? () => setState(() => _isRemoveMode = true) : null,
          ),
        ],
      ),
    );
  }

  Widget _modeToggleBtn({
    required String label,
    required IconData icon,
    required bool active,
    VoidCallback? onTap,
  }) {
    final theme_color = Theme.of(context).primaryColor;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? theme_color.withOpacity(0.08) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? theme_color : Colors.black.withOpacity(0.1),
              width: active ? 1.2 : 0.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16,
                  color: active ? theme_color : Colors.grey.shade500),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  color: active ? theme_color : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====================== Submit Button ======================
  Widget _SubmitButton(BuildContext context) {
    final isRemove = _isRemoveMode && hasLocation;
    final theme_color = Theme.of(context).primaryColor;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: TextButton(
          onPressed: _isSubmitting ? null : () => _onSubmit(context),
          style: TextButton.styleFrom(
            backgroundColor: isRemove ? Colors.white : theme_color,
            side: isRemove
                ? const BorderSide(color: Color(0xFFE53935), width: 1.5)
                : BorderSide.none,
          ),
          child: _isSubmitting
              ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: isRemove ? const Color(0xFFE53935) : Colors.white,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isRemove
                    ? Icons.delete_outline_rounded
                    : Icons.check_rounded,
                color: isRemove ? const Color(0xFFE53935) : Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isRemove
                    ? AppLocalizations.of(context)!.remove
                    : AppLocalizations.of(context)!.submit,
                style: TextStyle(
                  color:
                  isRemove ? const Color(0xFFE53935) : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====================== Actions ======================
  Future<void> _onSubmit(BuildContext context) async {
    setState(() => _isSubmitting = true);

    if (!_isRemoveMode) {
      await api_links().AddNewMap(
        context,
        MAP.center.latitude.toString(),
        MAP.center.longitude.toString(),
      );
    } else {
      await api_links().RemoveMap(context);
    }

    _navigateHome(context);
  }

  void _navigateHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => activity_home()),
          (route) => false,
    );
  }

  Future<bool> _onBackPressed() async {
    _navigateHome(context);
    return false;
  }

  // ====================== Small Helpers ======================
  Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 22, color: const Color(0xFF555555)),
      ),
    );
  }
}

// ====================== Center Pin Widget ======================
class _CenterPin extends StatefulWidget {
  const _CenterPin();

  @override
  State<_CenterPin> createState() => _CenterPinState();
}

class _CenterPinState extends State<_CenterPin>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bounce;
  late Animation<double> _shadow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _bounce = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _shadow = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme_color = Theme.of(context).primaryColor;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: Offset(0, _bounce.value),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: theme_color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(17),
                  topRight: Radius.circular(17),
                  bottomLeft: Radius.circular(17),
                  bottomRight: Radius.zero,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme_color.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Transform.scale(
            scale: _shadow.value,
            child: Container(
              width: 14,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================== Pulsing Dot Widget ======================
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _scale = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _opacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme_color = Theme.of(context).primaryColor;
    return SizedBox(
      width: 14,
      height: 14,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Transform.scale(
              scale: _scale.value,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme_color.withOpacity(_opacity.value),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}