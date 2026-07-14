import 'package:iziot/Widget/GetUserPosition.dart';
import 'package:iziot/Widget/TopBar.dart';
import 'package:iziot/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../Server/Server.dart';

class activity_location_picker extends StatefulWidget {
  const activity_location_picker({Key? key}) : super(key: key);

  @override
  State<activity_location_picker> createState() =>
      _activity_location_picker_state();
}

class _activity_location_picker_state extends State<activity_location_picker> {
  final MapController _mapController = MapController();

  bool get _hasUserPos =>
      UserPosition.Loc_Lat != 0.0 || UserPosition.Loc_Lng != 0.0;

  LatLng get _initialCenter => _hasUserPos
      ? LatLng(UserPosition.Loc_Lat, UserPosition.Loc_Lng)
      : const LatLng(35.6892, 51.3890);

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Column(
          children: [
            // ── Top bar ─────────────────────────────────────
            TopBar(context, true),

            // ── Map ─────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: _initialCenter,
                      zoom: 16.0,
                      maxZoom: 18.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: Server.Root_Address +
                            '/tile/proxy.php?layer=standard&z={z}&x={x}&y={y}',
                        userAgentPackageName: 'ir.izino.bzhub',
                        maxNativeZoom: 18,
                      ),
                      MarkerLayer(
                        markers: [
                          // GPS dot
                          if (_hasUserPos)
                            Marker(
                              point: LatLng(
                                  UserPosition.Loc_Lat, UserPosition.Loc_Lng),
                              width: 22,
                              height: 22,
                              builder: (_) => Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2196F3),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2196F3)
                                          .withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  // ── Center pin (fixed, map moves under it) ──
                  Center(
                    child: _CenterPin(),
                  ),

                  // ── Zoom controls ───────────────────────────
                  Positioned(
                    left: 14,
                    bottom: 14,
                    child: _buildZoomControls(theme),
                  ),

                  // ── Go to my location ───────────────────────
                  if (_hasUserPos)
                    Positioned(
                      right: 14,
                      bottom: 14,
                      child: GestureDetector(
                        onTap: () => _mapController.move(
                          LatLng(UserPosition.Loc_Lat, UserPosition.Loc_Lng),
                          16.0,
                        ),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black26, blurRadius: 6)
                            ],
                          ),
                          child: Icon(Icons.my_location_rounded,
                              color: theme.primaryColor, size: 20),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Bottom panel ─────────────────────────────────
            _buildBottomPanel(theme, loc),
          ],
        ),
      ),
    );
  }

  // ── Zoom controls ─────────────────────────────────────────
  Widget _buildZoomControls(ThemeData theme) {
    return Column(
      children: [
        _zoomBtn(icon: Icons.add,
            onTap: () =>
                _mapController.move(_mapController.center, _mapController.zoom + 1)),
        const SizedBox(height: 6),
        _zoomBtn(icon: Icons.remove,
            onTap: () =>
                _mapController.move(_mapController.center, _mapController.zoom - 1)),
      ],
    );
  }

  Widget _zoomBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF444444)),
      ),
    );
  }

  // ── Bottom panel ──────────────────────────────────────────
  Widget _buildBottomPanel(ThemeData theme, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: theme.splashColor,
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.06), width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: theme.primaryColor,
            ),
            onPressed: () {
              // Return the current map center as the picked location
              Navigator.pop(context, _mapController.center);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  loc.send_location,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Center Pin Widget (Static & Exact Alignment) ────────────────
class _CenterPin extends StatelessWidget {
  const _CenterPin();

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).primaryColor;

    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: 14,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Positioned(
            bottom: 35,
            right: 34,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(17),
                  topRight: Radius.circular(17),
                  bottomLeft: Radius.circular(17),
                  bottomRight: Radius.zero,
                ),
                // boxShadow: [
                //   BoxShadow(
                //     color: themeColor.withOpacity(0.35),
                //     blurRadius: 8,
                //     offset: const Offset(0, 3),
                //   ),
                // ],
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
        ],
      ),
    );
  }
}