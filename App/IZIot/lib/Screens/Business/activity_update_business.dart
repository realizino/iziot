import 'dart:typed_data';

import 'package:iziot/Data/Colors/App_Colors.dart';
import 'package:iziot/Models/Business/Business_Model.dart';
import 'package:iziot/Widget/TopBar.dart';
import 'package:iziot/api/Bueiness/api_business.dart';
import 'package:iziot/api/Links/api_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:iziot/Models/Categories/Categories_Model.dart';
import 'package:iziot/api/Categories/api_categories.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Models/Link/BLink_Model.dart';
import '../../Server/Server.dart';
import '../../Services/Maps/CachedTileProvider.dart';
import '../../api/BusinessLinks/api_business_links.dart';
import '../../l10n/app_localizations.dart';

class activity_update_business extends StatefulWidget {
  final Business_Model model;
  final bool isEditable;

  const activity_update_business({
    super.key,
    required this.model,
    this.isEditable = true,
  });

  @override
  State<activity_update_business> createState() => _ActivityUpdateBusinessState();
}

class _ActivityUpdateBusinessState extends State<activity_update_business> {
  Color get _primary => App_Colors.Theme_Color;
  Color get _bgCard => Theme.of(context).splashColor;
  Color get _bgPage => Theme.of(context).scaffoldBackgroundColor;
  Color get _textMain => Theme.of(context).unselectedWidgetColor;
  Color get _textSub => Theme.of(context).disabledColor;

  List<Categories_Model> _categories = [];
  List<String> _selectedKeywords = [];
  bool _loadingCats = true;

  List<BLink_Model> _links = [];
  bool _loadingLinks = true;
  String? _removingLinkId;

  bool get isRtl {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == "fa" || lang == "ar";
  }

  int currentTab = 0;
  bool isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _openAtController;
  late TextEditingController _closeAtController;

  final MapController _mapController = MapController();
  late double _selectedLat;
  late double _selectedLng;

  // User location tracking
  Position? _userPosition;
  bool _isTrackingLocation = false;

  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  late String _selectedLanguage;

  final List<Map<String, String>> _languages = [
    {"code": "fa", "label": "فارسی", "flag": "assets/Images/Iran_Flag.png"},
    {"code": "en", "label": "English", "flag": "assets/Images/USA_Flag.png"},
    {"code": "tr", "label": "Türkçe", "flag": "assets/Images/Turk_Flag.png"},
    {"code": "ar", "label": "العربية", "flag": "assets/Images/Arab_Flag.png"},
    {"code": "fr", "label": "Français", "flag": "assets/Images/Franc_Flag.png"},
    {"code": "es", "label": "Español", "flag": "assets/Images/Snain_Flag.png"},
    {"code": "ru", "label": "Русский", "flag": "assets/Images/Russia_Flag.png"},
    {"code": "zh", "label": "中文", "flag": "assets/Images/China_Flag.png"},
    {"code": "it", "label": "Italiano", "flag": "assets/Images/Italya_Flag.png"},
    {"code": "de", "label": "Deutsch", "flag": "assets/Images/German_Flag.png"},
  ];

  @override
  void initState() {
    super.initState();

    // Set status bar style once on init to avoid repeated calls on rebuild
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final model = widget.model;

    _nameController = TextEditingController(text: model.name);
    _bioController = TextEditingController(text: model.bio);
    _addressController = TextEditingController(text: model.address);
    _phoneController = TextEditingController(text: model.phone);
    _openAtController = TextEditingController(text: model.open_at);
    _closeAtController = TextEditingController(text: model.close_at);

    _selectedLat = double.tryParse(model.lat) ?? 35.6892;
    _selectedLng = double.tryParse(model.lng) ?? 51.3890;
    _selectedLanguage = model.language.isEmpty ? "en" : model.language;

    _selectedKeywords = widget.model.keywords
        .split(",")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
      _loadLinks();
    });
  }

  Future<void> _loadCategories() async {
    try {
      final tree = await api_categories().GetCategories(context);
      if (!mounted) return;
      setState(() {
        _categories = tree;
        _loadingCats = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingCats = false);
    }
  }

  Future<void> _loadLinks() async {
    setState(() => _loadingLinks = true);
    try {
      final links = await api_business_links().GetBusinessLinks(
        context,
        business_id: widget.model.id,
      );
      if (!mounted) return;
      setState(() {
        _links = links;
        _loadingLinks = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingLinks = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_isTrackingLocation) return;
    setState(() => _isTrackingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          _showError(AppLocalizations.of(context)!.please_enable_gps);
        }
        setState(() => _isTrackingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            _showError(AppLocalizations.of(context)!.location_permission_denied);
          }
          setState(() => _isTrackingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showError(AppLocalizations.of(context)!.location_permission_permanently_denied);
        }
        setState(() => _isTrackingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _userPosition = position;
          _isTrackingLocation = false;
        });

        // Move map to user's location
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          15.5,
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) {
        setState(() => _isTrackingLocation = false);
        _showError('${AppLocalizations.of(context)!.error_getting_location}: $e');
      }
    }
  }

  void _toggleKeyword(String title) {
    setState(() {
      if (_selectedKeywords.contains(title)) {
        _selectedKeywords.remove(title);
      } else {
        _selectedKeywords.add(title);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _openAtController.dispose();
    _closeAtController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    return _nameController.text.trim().isNotEmpty &&
        _bioController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _addressController.text.trim().isNotEmpty &&
        _openAtController.text.trim().isNotEmpty &&
        _closeAtController.text.trim().isNotEmpty;
  }

  Future<void> _pickImage() async {
    if (!widget.isEditable) return;
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() {
      _selectedImage = image;
      _selectedImageBytes = bytes;
    });
  }

  Future<void> _selectTime(TextEditingController controller) async {
    if (!widget.isEditable) return;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: App_Colors.Theme_Color,
              onPrimary: Colors.white,
              surface: theme.splashColor,
              onSurface: theme.unselectedWidgetColor,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: theme.splashColor,
              hourMinuteColor: theme.scaffoldBackgroundColor,
              hourMinuteTextColor: theme.unselectedWidgetColor,
              dialBackgroundColor: theme.scaffoldBackgroundColor,
              dialHandColor: App_Colors.Theme_Color,
              dialTextColor: theme.unselectedWidgetColor,
              dayPeriodColor: App_Colors.Theme_Color.withOpacity(0.12),
              dayPeriodTextColor: theme.unselectedWidgetColor,
              entryModeIconColor: App_Colors.Theme_Color,
              helpTextStyle: TextStyle(
                color: theme.disabledColor,
                fontSize: 12,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: App_Colors.Theme_Color,
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      setState(() {
        controller.text = "$hour:$minute";
      });
    }
  }

  Future<void> _submit() async {
    if (!_validateForm()) {
      _showError(AppLocalizations.of(context)!.please_fill_all_fieilds);
      return;
    }

    setState(() => isLoading = true);

    final result = await api_business().UpdateBusiness(
      context,
      id: widget.model.id,
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      lat: _selectedLat.toString(),
      lng: _selectedLng.toString(),
      open_at: _openAtController.text.trim(),
      close_at: _closeAtController.text.trim(),
      language: _selectedLanguage,
      keywords: _selectedKeywords.join(","),
      image: _selectedImage,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (result) {
      _showSuccess(AppLocalizations.of(context)!.buz_updated);
      Navigator.pop(context, true);
    } else {
      _showError(AppLocalizations.of(context)!.error_in_storage_data);
    }
  }

  @override
  Widget build(BuildContext context) {
    // SafeArea is only on body — Scaffold sits at root level
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _bgPage,
        body: SafeArea(
          child: Column(
            children: [
              TopBar(context, true),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        title: AppLocalizations.of(context)!.lie_info,
                        icon: Icons.info_outline,
                        index: 0,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTabButton(
                        title: AppLocalizations.of(context)!.location,
                        icon: Icons.location_on_outlined,
                        index: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTabButton(
                        title: AppLocalizations.of(context)!.links,
                        icon: Icons.link,
                        index: 3,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTabButton(
                        title: AppLocalizations.of(context)!.settings,
                        icon: Icons.settings_outlined,
                        index: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
                  child: _buildTabContent(),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: widget.isEditable
            ? FloatingActionButton.extended(
          onPressed: isLoading ? null : _submit,
          backgroundColor: _primary,
          elevation: 2,
          icon: isLoading
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : const Icon(Icons.save_rounded, color: Colors.white),
          label: Text(
            AppLocalizations.of(context)!.save_chages,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
            : null,
      ),
    );
  }

  // ==================== Tab Button ====================
  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required int index,
  }) {
    bool isActive = currentTab == index;
    return InkWell(
      onTap: () => setState(() => currentTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? _primary : _bgCard,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : _textSub,
              size: 24,
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? Colors.white : _textSub,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (currentTab) {
      case 0:
        return _buildInfoTab();
      case 1:
        return _buildLocationTab();
      case 2:
        return _buildSettingsTab();
      case 3:
        return _buildLinksTab();
      default:
        return const SizedBox();
    }
  }

  // ==================== Info Tab ====================
  Widget _buildInfoTab() {
    return Column(
      children: [
        _buildCard(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 130,
                        height: 130,
                        color: _bgPage,
                        child: _selectedImageBytes != null
                            ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                            : widget.model.image.isEmpty
                            ? Icon(Icons.store_rounded, size: 48, color: _textSub)
                            : Image.network(
                          widget.model.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Icon(Icons.store_rounded, size: 48, color: _textSub),
                        ),
                      ),
                    ),
                    if (widget.isEditable)
                      Positioned(
                        right: isRtl ? 6 : null,
                        left: isRtl ? null : 6,
                        bottom: 6,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: _primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _primary.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 15, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(context)!.for_change_click_on_image,
                style: TextStyle(fontSize: 11, color: _textSub),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildCard(
          child: Column(
            children: [
              _buildTextField(controller: _nameController, hint: AppLocalizations.of(context)!.bu_name, icon: Icons.store_outlined),
              const SizedBox(height: 12),
              _buildTextField(controller: _bioController, hint: AppLocalizations.of(context)!.dit, icon: Icons.description_outlined, maxLines: 3),
              const SizedBox(height: 12),
              _buildTextField(controller: _phoneController, hint: AppLocalizations.of(context)!.sample_phone, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildCard(
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectTime(_openAtController),
                  child: _buildTextField(controller: _openAtController, hint: AppLocalizations.of(context)!.start_job, icon: Icons.lock_open_rounded, enabled: false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectTime(_closeAtController),
                  child: _buildTextField(controller: _closeAtController, hint: AppLocalizations.of(context)!.end_job, icon: Icons.lock_rounded, enabled: false),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== Location Tab ====================
  Widget _buildLocationTab() {
    return Column(
      children: [
        _buildCard(
          child: _buildTextField(
            controller: _addressController,
            hint: AppLocalizations.of(context)!.address_fully,
            icon: Icons.location_on_outlined,
            maxLines: 2,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.42,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: LatLng(_selectedLat, _selectedLng),
                    zoom: 15.5,
                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture && position.center != null && widget.isEditable) {
                        setState(() {
                          _selectedLat = position.center!.latitude;
                          _selectedLng = position.center!.longitude;
                        });
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: Server.Root_Address + '/tile/proxy.php?layer=standard&z={z}&x={x}&y={y}',
                      userAgentPackageName: 'ir.izino.bzhub',
                      maxNativeZoom: 18,
                      minNativeZoom: 3,
                      keepBuffer: 2,
                      panBuffer: 1,
                      tileProvider: CachedTileProvider(
                        maxDiskCacheAge: const Duration(days: 365),
                        maxMemoryCacheEntries: 100,
                      ),
                    ),
                    if (_userPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
                            width: 40,
                            height: 40,
                            builder: (_) => Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF4285F4).withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4285F4),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: _CenterPin(),
                  ),
                ),
                if (widget.isEditable)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: FloatingActionButton(
                      heroTag: 'my_location_business',
                      mini: true,
                      backgroundColor: _userPosition != null ? _primary : Colors.grey,
                      elevation: 3,
                      onPressed: _isTrackingLocation
                          ? null
                          : () {
                        if (_userPosition != null) {
                          _mapController.move(
                            LatLng(_userPosition!.latitude, _userPosition!.longitude),
                            15.5,
                          );
                        } else {
                          _getCurrentLocation();
                        }
                      },
                      child: _isTrackingLocation
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.my_location, color: Colors.white, size: 20),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "${_selectedLat.toStringAsFixed(6)}, ${_selectedLng.toStringAsFixed(6)}",
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF22C55E),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  // ==================== Settings Tab ====================
  Widget _buildKeywordsStep() {
    if (_loadingCats) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CircularProgressIndicator(color: _primary, strokeWidth: 2),
        ),
      );
    }
    if (_categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          AppLocalizations.of(context)!.category_not_found,
          style: TextStyle(fontSize: 13, color: _textSub),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._categories.map(
              (root) => Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: PageStorageKey('update_cat_${root.id}'),
              tilePadding: EdgeInsets.zero,
              title: Text(
                root.title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textMain),
              ),
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: root.children.map((child) {
                    final selected = _selectedKeywords.contains(child.title);
                    return FilterChip(
                      label: Text(child.title),
                      selected: selected,
                      onSelected: widget.isEditable ? (_) => _toggleKeyword(child.title) : null,
                      selectedColor: _primary,
                      checkmarkColor: Colors.white,
                      backgroundColor: _bgPage,
                      side: BorderSide(color: selected ? _primary : Theme.of(context).dividerColor, width: 1),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: selected ? Colors.white : _textSub,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        if (_selectedKeywords.isNotEmpty) ...[
          const SizedBox(height: 12),
          Divider(color: Theme.of(context).dividerColor, height: 1),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.selected_category,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textSub),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _selectedKeywords.map((kw) {
              return Chip(
                label: Text(kw, style: const TextStyle(fontSize: 12, color: Colors.white)),
                deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white),
                onDeleted: widget.isEditable ? () => _toggleKeyword(kw) : null,
                backgroundColor: _primary,
                deleteIconColor: Colors.white,
                side: BorderSide.none,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSettingsTab() {
    return Column(
      children: [
        _buildCard(child: _buildKeywordsStep()),
        const SizedBox(height: 12),
        _buildCard(
          child: Column(
            children: _languages.map((lang) {
              final isSelected = _selectedLanguage == lang["code"];
              return GestureDetector(
                onTap: widget.isEditable ? () => setState(() => _selectedLanguage = lang["code"]!) : null,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? _primary.withOpacity(0.08) : _bgPage,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? _primary : Theme.of(context).dividerColor, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Image.asset(lang["flag"]!, width: 28, height: 20),
                      const SizedBox(width: 12),
                      Text(
                        lang["label"]!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? _primary : _textMain,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected) Icon(Icons.check_circle_rounded, size: 20, color: _primary),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (widget.isEditable) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: isLoading ? null : _deleteBusiness,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.25), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red[400]),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.remove_buz,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.red[400]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ==================== Links Tab ====================
  Widget _buildLinksTab() {
    if (_loadingLinks) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: CircularProgressIndicator(color: _primary, strokeWidth: 2),
        ),
      );
    }

    return Column(
      children: [
        if (_links.isEmpty)
          _buildCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.links_is_empty,
                  style: TextStyle(fontSize: 13, color: _textSub),
                ),
              ),
            ),
          )
        else
          ..._links.asMap().entries.map((entry) => _buildLinkItem(entry.value, entry.key)).toList(),
        if (widget.isEditable) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _showAddLinkDialog,
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: Text(
                AppLocalizations.of(context)!.add_new_link,
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLinkItem(BLink_Model link, int index) {
    final bool isPhone = _isNumeric(link.link);
    final bool isTelegram = link.link.contains("t.me");
    final bool isWhatsapp = link.link.contains("wa.me");

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
      final cleanLink = link.link.replaceAll("https://", "").replaceAll("http://", "").replaceAll("www.", "");
      domainLabel = _getDomain(link.link);
      faviconUrl = "https://www.google.com/s2/favicons?domain=${cleanLink.split('/').first}&sz=256";
    }

    final String displayLink = link.link.endsWith("/")
        ? link.link.substring(0, link.link.length - 1).replaceAll("www.", "")
        : link.link.replaceAll("www.", "");

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _buildCard(
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => _showLinkContextMenu(link),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _bgPage,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: isPhone
                          ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset("assets/icons/phone-call.png", fit: BoxFit.contain),
                      )
                          : Image.network(
                        faviconUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.link, color: _textSub, size: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(domainLabel, style: TextStyle(fontSize: 11, color: _textSub)),
                        const SizedBox(height: 2),
                        Text(
                          displayLink,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textMain),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.more_vert, color: _textSub, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showLinkContextMenu(BLink_Model link) async {
    showDialog(
      context: context,
      barrierColor: const Color(0x66000000),
      builder: (_) => Dialog(
        backgroundColor: _bgCard,
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
                  color: _bgPage,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _DialogBtn(
                icon: Icons.open_in_new_rounded,
                label: AppLocalizations.of(context)!.open,
                color: _primary,
                onTap: () async {
                  Navigator.pop(context);
                  final url = _isNumeric(link.link) ? "tel:${link.link}" : "https://${link.link}";
                  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                },
              ),
              const SizedBox(height: 8),
              _DialogBtn(
                icon: Icons.copy_rounded,
                label: AppLocalizations.of(context)!.copy,
                color: const Color(0xFF3B82F6),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: link.link));
                  Navigator.pop(context);
                  _showSuccess(AppLocalizations.of(context)!.copied);
                },
              ),
              if (widget.isEditable) ...[
                const SizedBox(height: 8),
                StatefulBuilder(
                  builder: (ctx, setLocal) => _DialogBtn(
                    icon: Icons.delete_outline_rounded,
                    label: AppLocalizations.of(context)!.remove,
                    color: Colors.red,
                    loading: _removingLinkId == link.id.toString(),
                    onTap: () async {
                      setLocal(() => setState(() => _removingLinkId = link.id.toString()));
                      try {
                        await api_business_links().RemoveLink(context, id: link.id);
                        _loadLinks();
                        Navigator.pop(context);
                        _showSuccess(AppLocalizations.of(context)!.link_removed);
                      } catch (_) {
                        _showError(AppLocalizations.of(context)!.error_when_removed);
                      } finally {
                        if (mounted) setState(() => _removingLinkId = null);
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddLinkDialog() async {
    final TextEditingController linkController = TextEditingController();
    await showDialog(
      context: context,
      barrierColor: const Color(0x66000000),
      builder: (_) => Dialog(
        backgroundColor: _bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppLocalizations.of(context)!.add_NN_link, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textMain)),
              const SizedBox(height: 14),
              TextField(
                controller: linkController,
                style: TextStyle(fontSize: 14, color: _textMain),
                keyboardType: TextInputType.url,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: "https://example.com",
                  hintStyle: TextStyle(fontSize: 13, color: _textSub),
                  contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                  fillColor: _bgPage,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _primary, width: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              StatefulBuilder(
                builder: (ctx, setLocal) {
                  bool isAdding = false;
                  return SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: isAdding ? null : () async {
                        final text = linkController.text.trim();
                        final uri = Uri.tryParse(text);
                        final isUrl = uri?.isAbsolute ?? false;
                        if (!isUrl && !_isNumeric(text)) {
                          _showError(AppLocalizations.of(context)!.link_not_valid);
                          return;
                        }
                        setLocal(() => isAdding = true);
                        try {
                          await api_business_links().AddBusinessLink(
                            context,
                            business_id: widget.model.id,
                            link: text,
                          );
                          Navigator.pop(context);
                          _loadLinks();
                          _showSuccess(AppLocalizations.of(context)!.link_added);
                        } catch (_) {
                          _showError(AppLocalizations.of(context)!.error_when_add_link);
                        } finally {
                          if (mounted) setLocal(() => isAdding = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: isAdding
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1.8))
                          : Text(AppLocalizations.of(context)!.add, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteBusiness() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x66000000),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Theme.of(context).splashColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(AppLocalizations.of(context)!.remove_bz_alert_title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textMain)),
            content: Text(AppLocalizations.of(context)!.remove_bz_alert_dec, style: TextStyle(fontSize: 13, color: _textSub, height: 1.6)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.cencel, style: TextStyle(color: _textSub)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppLocalizations.of(context)!.remove, style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      },
    );
    if (confirmed != true) return;
    setState(() => isLoading = true);
    final result = await api_business().DeleteBusiness(context, id: widget.model.id);
    if (!mounted) return;
    setState(() => isLoading = false);
    if (result) {
      _showSuccess(AppLocalizations.of(context)!.bz_removed);
      Navigator.pop(context, true);
    } else {
      _showError(AppLocalizations.of(context)!.error_when_bz_removing);
    }
  }

  bool _isNumeric(String text) => double.tryParse(text) != null;

  String _getDomain(String url) {
    try {
      String cleaned = url.trim();
      if (!cleaned.startsWith("http://") && !cleaned.startsWith("https://")) {
        cleaned = "https://$cleaned";
      }
      final host = Uri.parse(cleaned).host.replaceAll("www.", "");
      final parts = host.split(".");
      return (parts.isNotEmpty && parts.first.isNotEmpty) ? parts.first : url;
    } catch (_) {
      return url;
    }
  }

  // ==================== Helper Widgets ====================
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(14),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool? enabled,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled ?? widget.isEditable,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      onChanged: (_) => setState(() {}),
      style: TextStyle(fontSize: 13, color: _textMain),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: _textSub),
        prefixIcon: Icon(icon, size: 18, color: _textSub),
        filled: true,
        fillColor: _bgPage,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _primary, width: 1.5),
        ),
      ),
    );
  }
}

// ==================== Link Dialog Button ====================
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
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1.8))
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ==================== Animated Map Center Pin ====================
class _CenterPin extends StatefulWidget {
  const _CenterPin();
  @override
  State<_CenterPin> createState() => _CenterPinState();
}

class _CenterPinState extends State<_CenterPin> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bounce;
  late Animation<double> _shadow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _bounce = Tween<double>(begin: 0, end: -8).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _shadow = Tween<double>(begin: 1.0, end: 0.6).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = App_Colors.Theme_Color;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: Offset(0, _bounce.value),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.zero,
                ),
                boxShadow: [BoxShadow(color: themeColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Center(
                child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              ),
            ),
          ),
          Transform.scale(
            scale: _shadow.value,
            child: Container(
              width: 16,
              height: 6,
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}