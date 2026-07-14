import 'dart:async';
import 'dart:io';

import 'package:iziot/Components/ComponentSliderFromLinks.dart';
import 'package:iziot/Data/Colors/App_Colors.dart';
import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/Models/Categories/Categories_Model.dart';
import 'package:iziot/Models/User/MapUsers_Model.dart';
import 'package:iziot/Screens/User/activity_display.dart';
import 'package:iziot/api/Categories/api_categories.dart';
import 'package:iziot/api/Community/api_community.dart';
import 'package:iziot/api/Map/api_map_business.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Server/Server.dart';
import '../Services/Maps/CachedTileProvider.dart';
import '../l10n/app_localizations.dart';

/// In-memory cache shared across every time [MapsLayout] is built (e.g.
/// switching tabs and coming back). Avoids re-hitting the API for data
/// that hasn't changed since the last fetch, which was the main thing
/// making the screen feel slow on re-entry.
class _MapDataCache {
  static List<MapUsers_Model>? users;
  static DateTime? usersFetchedAt;
  static String? usersKeyword;

  static List<Categories_Model>? categories;
  static DateTime? categoriesFetchedAt;

  static const Duration usersTtl = Duration(minutes: 2);
  static const Duration categoriesTtl = Duration(hours: 6);

  static bool get hasFreshUsers =>
      users != null &&
          usersKeyword == null &&
          usersFetchedAt != null &&
          DateTime.now().difference(usersFetchedAt!) < usersTtl;

  static bool get hasFreshCategories =>
      categories != null &&
          categoriesFetchedAt != null &&
          DateTime.now().difference(categoriesFetchedAt!) < categoriesTtl;
}

enum MapLayerType { standard, humanitarian, terrain, satellite }

class MapsLayout extends StatefulWidget {
  final Function(LatLng)? onTap;
  final MapController? externalController;

  const MapsLayout({
    Key? key,
    this.onTap,
    this.externalController,
  }) : super(key: key);

  @override
  State<MapsLayout> createState() => _MapsLayoutState();
}

class _MapsLayoutState extends State<MapsLayout>
    with SingleTickerProviderStateMixin {
  late final MapController mapController;
  late final SuperclusterMutableController superclusterController;
  late final AnimationController _animationController;

  List<MapUsers_Model> _users = [];
  Map<String, MapUsers_Model> _userMap = {};
  Set<String> _selectedCategoryTitles = {};

  MapLayerType _currentLayer = MapLayerType.standard;
  bool _isFilterLoading = false;
  bool _mapCentered = false;

  int _loadToken = 0;

  // Track the current map rotation (radians) for the compass button
  double _mapRotation = 0.0;

  // User location tracking
  Position? _userPosition;
  bool _isTrackingLocation = false;

  @override
  void initState() {
    super.initState();
    mapController = widget.externalController ?? MapController();
    superclusterController = SuperclusterMutableController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    // Get user's current location on init
    _getCurrentLocation();

    // If we already have fresh cached community data, paint it
    // immediately (no spinner, no network wait), then only go to the
    // network if the cache is missing/expired.
    if (_MapDataCache.hasFreshUsers) {
      _users = _MapDataCache.users!;
      _userMap = {for (final u in _users) u.id.toString(): u};
      // Refresh quietly in the background without a loading indicator.
      _loadUsers(silent: true);
    } else {
      _loadUsers();
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_isTrackingLocation) return;
    setState(() => _isTrackingLocation = true);

    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.please_enable_gps),
            ),
          );
        }
        setState(() => _isTrackingLocation = false);
        return;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.location_permission_denied),
              ),
            );
          }
          setState(() => _isTrackingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.location_permission_permanently_denied),
            ),
          );
        }
        setState(() => _isTrackingLocation = false);
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _userPosition = position;
          _isTrackingLocation = false;
        });

        // Center map on user's location (only first time)
        if (!_mapCentered) {
          _animatedMapMove(
            LatLng(position.latitude, position.longitude),
            15.5,
          );
          _mapCentered = true;
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) {
        setState(() => _isTrackingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.error_getting_location}: $e'),
          ),
        );
      }
    }
  }

  Future<void> _openExternalNavigation(double lat, double lng) async {
    Uri uri;
    if (Platform.isIOS) {
      uri = Uri.parse('https://maps.apple.com/?daddr=$lat,$lng&dirflg=d');
    } else {
      uri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final fallback = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    superclusterController.dispose();
    super.dispose();
  }

  void _animatedMapMove(LatLng destination, double zoom) {
    final latTween = Tween<double>(
      begin: mapController.center.latitude,
      end: destination.latitude,
    );
    final lngTween = Tween<double>(
      begin: mapController.center.longitude,
      end: destination.longitude,
    );
    final zoomTween = Tween<double>(
      begin: mapController.zoom,
      end: zoom,
    );

    final animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    _animationController.reset();

    animation.addListener(() {
      if (!mounted) return;
      mapController.move(
        LatLng(
          latTween.evaluate(animation),
          lngTween.evaluate(animation),
        ),
        zoomTween.evaluate(animation),
      );
    });

    _animationController.forward();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────
  bool get isRtl {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == "fa" || lang == "ar";
  }

  // ─── Data ────────────────────────────────────────────────────────────────
  Future<void> _loadUsers({String? keywords, bool silent = false}) async {
    final token = ++_loadToken;

    // A "silent" refresh (used when we already painted cached data) skips
    // the loading spinner so it doesn't flicker on every re-entry.
    if (!silent) {
      setState(() => _isFilterLoading = true);
    }

    try {
      final users = (keywords != null && keywords.isNotEmpty)
          ? await api_community().GetAllCommunityByKeyword(context, keywords)
          : await api_community().GetAllCommunity(context);

      if (!mounted || token != _loadToken) return;

      final map = <String, MapUsers_Model>{};
      for (final u in users) {
        map[u.id.toString()] = u;
      }

      setState(() {
        _users = users;
        _userMap = map;
      });

      // Cache unfiltered results only, so a keyword-filtered fetch never
      // overwrites the general "all community" cache used on next entry.
      if (keywords == null || keywords.isEmpty) {
        _MapDataCache.users = users;
        _MapDataCache.usersFetchedAt = DateTime.now();
        _MapDataCache.usersKeyword = null;
      } else {
        _MapDataCache.usersKeyword = keywords;
      }

      // Update supercluster markers
      superclusterController.replaceAll(_buildUserMarkers());

      // Center map on the first community user's location only as a
      // fallback, and only if the device GPS position is not available.
      if (!_mapCentered && _userPosition == null) {
        if (Strings.UserData.lat.isNotEmpty &&
            Strings.UserData.lng.isNotEmpty) {
          final lat = double.tryParse(Strings.UserData.lat) ?? 35.6892;
          final lng = double.tryParse(Strings.UserData.lng) ?? 51.3890;
          mapController.move(LatLng(lat, lng), 14.0);
        } else {
          mapController.move(const LatLng(35.6892, 51.3890), 14.0);
        }
        _mapCentered = true;
      }
    } catch (e) {
      debugPrint("Error loading users: $e");
    } finally {
      if (mounted && token == _loadToken && !silent) {
        setState(() => _isFilterLoading = false);
      }
    }
  }

  // ─── Initial center ─────────────────────────────────────────────────────
  LatLng _initialCenter() {
    if (_userPosition != null) {
      return LatLng(_userPosition!.latitude, _userPosition!.longitude);
    }
    if (Strings.UserData.lat.isNotEmpty && Strings.UserData.lng.isNotEmpty) {
      return LatLng(
        double.tryParse(Strings.UserData.lat) ?? 35.6892,
        double.tryParse(Strings.UserData.lng) ?? 51.3890,
      );
    }
    return const LatLng(35.6892, 51.3890);
  }

  // ─── Tile URL ────────────────────────────────────────────────────────────
  String _tileUrl(MapLayerType type) {
    final layer = switch (type) {
      MapLayerType.standard => 'standard',
      MapLayerType.humanitarian => 'humanitarian',
      MapLayerType.terrain => 'terrain',
      MapLayerType.satellite => 'satellite',
    };
    return Server.Root_Address +
        '/tile/proxy.php?layer=$layer&z={z}&x={x}&y={y}';
  }

  // ─── Zoom caps to prevent white tiles at high zoom ─────────────────────
  int _maxNativeZoom(MapLayerType type) =>
      type == MapLayerType.terrain ? 17 : 18;

  // ─── Marker tap handling (shared by desktop + mobile) ──────────────────
  // Data fetch now fires immediately, in parallel with the camera
  // animation, instead of waiting ~450ms for the animation to finish.
  void _handleMarkerTap(Marker marker) {
    final key = marker.key;
    if (key is! ValueKey<String>) return;

    final user = _userMap[key.value];
    if (user == null) return;

    final lat = double.tryParse(user.lat) ?? 35.6892;
    final lng = double.tryParse(user.lng) ?? 51.3890;
    final target = LatLng(lat, lng);

    // Purely visual, fire-and-forget.
    _animatedMapMove(target, 16.5);

    // Fetch/navigate immediately, no need to wait on the animation.
    if (user.type == 'BUSINESS') {
      api_map_business().GetBusiness(context, user, mounted);
    } else {
      Strings.DeepLink = user.username;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => activity_display()),
      );
    }
  }

  void _handleClusterTap(LatLng position) {
    _animatedMapMove(position, mapController.zoom + 2.8);
  }

  // ─── Build ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDesktop = MediaQuery.of(context).size.width >= 600;

    final bool haveSlider = (Strings.Config["slider"] == "-") ? false : true;
    final bool showDesktopLayout = isDesktop && haveSlider;

    final mapStack = Stack(
      children: [
        Positioned.fill(
          child: showDesktopLayout
              ? Padding(
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: _buildMap(theme),
            ),
          )
              : _buildMap(theme),
        ),

        // ─── Compass button – visible only when map is rotated ──────────
        if (_mapRotation.abs() > 0.01)
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => mapController.rotate(0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Transform.rotate(
                  angle: -_mapRotation,
                  child: const Icon(
                    Icons.navigation,
                    color: Colors.red,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),

        // ─── FABs ────────────────────────────────────────────────────────
        Positioned(
          bottom: 24,
          right: isRtl ? null : 20,
          left: isRtl ? 20 : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // My Location button
              FloatingActionButton(
                heroTag: 'my_location',
                mini: true,
                backgroundColor: _userPosition != null
                    ? theme.primaryColor
                    : Colors.grey,
                elevation: 3,
                onPressed: _isTrackingLocation
                    ? null
                    : () {
                  if (_userPosition != null) {
                    _animatedMapMove(
                      LatLng(_userPosition!.latitude, _userPosition!.longitude),
                      15.5,
                    );
                  } else {
                    _getCurrentLocation();
                  }
                },
                child: _isTrackingLocation
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.my_location, color: Colors.white),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'filter',
                mini: true,
                backgroundColor: _selectedCategoryTitles.isNotEmpty
                    ? theme.primaryColor
                    : theme.cardColor,
                elevation: 3,
                onPressed: _showCategoryFilter,
                child: Icon(
                  Icons.filter_list_rounded,
                  color: _selectedCategoryTitles.isNotEmpty
                      ? Colors.white
                      : theme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'layers',
                mini: true,
                backgroundColor: theme.primaryColor,
                elevation: 3,
                onPressed: _showLayerPicker,
                child: const Icon(Icons.layers_rounded, color: Colors.white),
              ),
            ],
          ),
        ),

        // ─── Filter loading indicator ────────────────────────────────────
        if (_isFilterLoading)
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8),
                  ],
                ),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: theme.primaryColor,
                ),
              ),
            ),
          ),

        // ─── Slider (mobile only) ─────────────────────────────────────────
        if (haveSlider && !isDesktop)
          Positioned(
            top: 5,
            left: 5,
            right: 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
              child: ComponentSliderFromLinks(
                rawData: Strings.Config["slider"].toString(),
                height: 70,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                showIndicator: false,
              ),
            ),
          ),
      ],
    );

    // ─── Desktop layout: slider on top, map below ──────────────────────────
    if (showDesktopLayout) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 10),
            child: ComponentSliderFromLinks(
              rawData: Strings.Config["slider"].toString(),
              height: 70,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              showIndicator: false,
            ),
          ),
          Expanded(child: mapStack),
        ],
      );
    }

    return mapStack;
  }

  // ─── Shared FlutterMap (desktop + mobile use the exact same widget) ─────
  Widget _buildMap(ThemeData theme) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: _initialCenter(),
        zoom: 14.0,
        minZoom: 3.0,
        maxZoom: 18.0,
        interactiveFlags: InteractiveFlag.all,
        onMapEvent: (_) {
          setState(() => _mapRotation = mapController.rotation);
        },
        onTap:
        widget.onTap != null ? (_, point) => widget.onTap!(point) : null,
      ),
      children: [
        TileLayer(
          urlTemplate: _tileUrl(_currentLayer),
          userAgentPackageName: 'ir.izino.bzhub',
          maxNativeZoom: _maxNativeZoom(_currentLayer),
          minNativeZoom: 3,
          keepBuffer: 2,
          panBuffer: 1,
          tileProvider: CachedTileProvider(
            maxDiskCacheAge: const Duration(days: 365),
            maxMemoryCacheEntries: 150,
          ),
          errorTileCallback: (tile, error, stackTrace) {
            debugPrint(
                "Tile load failed z=${tile.coordinates.z} x=${tile.coordinates.x} y=${tile.coordinates.y}: $error");
          },
        ),

        // ─── Supercluster layer ───────────────────────────────────────
        SuperclusterLayer.mutable(
          initialMarkers: _buildUserMarkers(),
          controller: superclusterController,
          clusterWidgetSize: const Size(40, 40),
          maxClusterRadius: 80,
          indexBuilder: IndexBuilders.rootIsolate,
          onMarkerTap: _handleMarkerTap,
          builder: (context, position, count, extraClusterData) {
            return GestureDetector(
              onTap: () => _handleClusterTap(position),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // ─── User location marker ─────────────────────────────────────
        MarkerLayer(
          markers: [
            if (_userPosition != null)
              Marker(
                point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
                width: 50,
                height: 50,
                builder: (_) => _UserLocationMarker(),
              ),
            if (Strings.UserData.lat.isNotEmpty &&
                Strings.UserData.lng.isNotEmpty)
              Marker(
                point: LatLng(
                  double.tryParse(Strings.UserData.lat) ?? 0,
                  double.tryParse(Strings.UserData.lng) ?? 0,
                ),
                width: 52,
                height: 52,
                builder: (_) => Icon(
                  Icons.location_pin,
                  color: theme.primaryColor,
                  size: 42,
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ─── Markers ────────────────────────────────────────────────────────────
  List<Marker> _buildUserMarkers() {
    return _users.map((user) {
      final lat = double.tryParse(user.lat) ?? 0.0;
      final lng = double.tryParse(user.lng) ?? 0.0;

      return Marker(
        key: ValueKey(user.id.toString()),
        point: LatLng(lat, lng),
        width: 56,
        height: 56,
        builder: (_) => GestureDetector(
          onLongPress: () => _openExternalNavigation(lat, lng),
          child: user.type == 'BUSINESS'
              ? _BusinessMarker(user: user)
              : _UserProfileMarker(user: user),
        ),
      );
    }).toList();
  }

  Widget _UserProfileMarker({required MapUsers_Model user}) {
    return CircleAvatar(
      backgroundColor: App_Colors.Theme_Color,
      radius: 24,
      child: user.profile_image.isNotEmpty
          ? ClipOval(
        child: Image.network(
          "${Server.Root_Address}/File/${user.profile_image}",
          fit: BoxFit.cover,
          width: 48,
          height: 48,
          cacheWidth: 96,
          cacheHeight: 96,
          errorBuilder: (_, __, ___) =>
              Image.asset("assets/icons/user_placeholder.png"),
        ),
      )
          : Image.asset("assets/icons/user_placeholder.png"),
    );
  }

  Widget _BusinessMarker({required MapUsers_Model user}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: App_Colors.Blue_Color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: user.profile_image.isNotEmpty
            ? Image.network(
          user.profile_image,
          fit: BoxFit.cover,
          cacheWidth: 96,
          cacheHeight: 96,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.store_rounded,
            color: Colors.white,
            size: 24,
          ),
        )
            : const Icon(
          Icons.store_rounded,
          color: Colors.white,
          size: 24,
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
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
        ),
      ],
    );
  }

  // ─── Bottom sheets ─────────────────────────────────────────────────────
  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CategoryFilterBottomSheet(
        initialSelected: _selectedCategoryTitles,
        onApply: (selectedTitles) {
          setState(() => _selectedCategoryTitles = Set.from(selectedTitles));
          final keywordStr = selectedTitles.join(',');
          _loadUsers(keywords: keywordStr.isNotEmpty ? keywordStr : null);
        },
      ),
    );
  }

  void _showLayerPicker() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      backgroundColor: theme.cardColor,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.unselectedWidgetColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              ...MapLayerType.values.map((type) => ListTile(
                leading: Icon(
                  _getLayerIcon(type),
                  color: _currentLayer == type
                      ? theme.primaryColor
                      : theme.unselectedWidgetColor,
                ),
                title: Text(
                  _getLayerName(type),
                  style: TextStyle(
                    color: _currentLayer == type
                        ? theme.primaryColor
                        : theme.unselectedWidgetColor,
                  ),
                ),
                selected: _currentLayer == type,
                onTap: () {
                  setState(() => _currentLayer = type);
                  Navigator.pop(ctx);
                },
              )),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  IconData _getLayerIcon(MapLayerType type) {
    switch (type) {
      case MapLayerType.standard:
        return Icons.map_outlined;
      case MapLayerType.humanitarian:
        return Icons.map;
      case MapLayerType.terrain:
        return Icons.terrain;
      case MapLayerType.satellite:
        return Icons.satellite_alt;
    }
  }

  String _getLayerName(MapLayerType type) {
    switch (type) {
      case MapLayerType.standard:
        return AppLocalizations.of(context)!.standard_map;
      case MapLayerType.humanitarian:
        return AppLocalizations.of(context)!.hu_map;
      case MapLayerType.terrain:
        return AppLocalizations.of(context)!.topo_map;
      case MapLayerType.satellite:
        return AppLocalizations.of(context)!.sattlite_map;
    }
  }
}

// ─── Category filter bottom sheet ───────────────────────────────────────────
class _CategoryFilterBottomSheet extends StatefulWidget {
  final Set<String> initialSelected;
  final Function(Set<String>) onApply;

  const _CategoryFilterBottomSheet({
    Key? key,
    required this.initialSelected,
    required this.onApply,
  }) : super(key: key);

  @override
  State<_CategoryFilterBottomSheet> createState() =>
      _CategoryFilterBottomSheetState();
}

class _CategoryFilterBottomSheetState
    extends State<_CategoryFilterBottomSheet> {
  bool _isLoading = true;
  List<Categories_Model> _categories = [];
  late Set<String> _selectedTitles;

  @override
  void initState() {
    super.initState();
    _selectedTitles = Set.from(widget.initialSelected);

    if (_MapDataCache.hasFreshCategories) {
      _categories = _MapDataCache.categories!;
      _isLoading = false;
    } else {
      _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await api_categories().GetCategories(context);
      _MapDataCache.categories = cats;
      _MapDataCache.categoriesFetchedAt = DateTime.now();
      if (mounted) {
        setState(() {
          _categories = cats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: theme.unselectedWidgetColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              loc.categories,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.unselectedWidgetColor,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: theme.primaryColor,
              ),
            )
                : ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) => _CategoryTile(
                category: _categories[index],
                selectedTitles: _selectedTitles,
                onChanged: (title, selected) {
                  setState(() {
                    selected
                        ? _selectedTitles.add(title)
                        : _selectedTitles.remove(title);
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _selectedTitles.clear()),
                    child: Text(loc.remove_filter),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_selectedTitles);
                      Navigator.pop(context);
                    },
                    child: Text(loc.add_filter),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category tile ──────────────────────────────────────────────────────────
class _CategoryTile extends StatelessWidget {
  final Categories_Model category;
  final Set<String> selectedTitles;
  final Function(String, bool) onChanged;

  const _CategoryTile({
    required this.category,
    required this.selectedTitles,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (category.children.isNotEmpty) {
      return ExpansionTile(
        collapsedIconColor: theme.unselectedWidgetColor,
        iconColor: theme.unselectedWidgetColor,
        title: Text(
          category.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.unselectedWidgetColor,
          ),
        ),
        children: category.children
            .map((child) => _CategoryTile(
          category: child,
          selectedTitles: selectedTitles,
          onChanged: onChanged,
        ))
            .toList(),
      );
    }

    return CheckboxListTile(
      title: Text(
        category.title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: theme.unselectedWidgetColor,
        ),
      ),
      value: selectedTitles.contains(category.title),
      onChanged: (val) => onChanged(category.title, val ?? false),
      activeColor: theme.primaryColor,
      checkColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      checkboxShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      side: BorderSide(
        color: theme.primaryColor.withOpacity(0.6),
        width: 2,
      ),
      selectedTileColor: theme.primaryColor.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}