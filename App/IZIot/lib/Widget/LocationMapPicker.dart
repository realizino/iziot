import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../Server/Server.dart';
import 'MapCenterPin.dart';

class LocationMapPicker extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final void Function(double lat, double lng) onLocationChanged;

  const LocationMapPicker({
    Key? key,
    required this.initialLat,
    required this.initialLng,
    required this.onLocationChanged,
  }) : super(key: key);

  @override
  State<LocationMapPicker> createState() => _LocationMapPickerState();
}

class _LocationMapPickerState extends State<LocationMapPicker> {
  final MapController _mapController = MapController();
  late double _lat;
  late double _lng;

  @override
  void initState() {
    super.initState();
    _lat = widget.initialLat;
    _lng = widget.initialLng;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 260,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: LatLng(_lat, _lng),
                    zoom: 15.5,
                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture && position.center != null) {
                        setState(() {
                          _lat = position.center!.latitude;
                          _lng = position.center!.longitude;
                        });
                        widget.onLocationChanged(_lat, _lng);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      // NOTE: confirm this matches the iziot backend tile proxy path
                      urlTemplate: Server.Root_Address + '/tile/proxy.php?layer=standard&z={z}&x={x}&y={y}',
                      userAgentPackageName: 'ir.izino.iziot',
                    ),
                  ],
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 22, right: 2),
                    child: MapCenterPin(),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "${_lat.toStringAsFixed(6)}, ${_lng.toStringAsFixed(6)}",
              style: TextStyle(
                fontSize: 12.5,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}