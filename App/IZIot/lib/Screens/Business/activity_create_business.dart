import 'dart:typed_data';

import 'package:iziot/Data/Colors/App_Colors.dart';
import 'package:iziot/Widget/TopBar.dart';
import 'package:iziot/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:iziot/Widget/GetUserPosition.dart';
import 'package:iziot/Models/Categories/Categories_Model.dart';
import 'package:iziot/api/Categories/api_categories.dart';
import 'package:latlong2/latlong.dart';
import '../../Server/Server.dart';
import '../../api/Bueiness/api_business.dart';
import '../../l10n/app_localizations.dart';

class activity_create_business extends StatefulWidget {
  const activity_create_business({super.key});

  @override
  State<activity_create_business> createState() => _ActivityCreateBusinessState();
}

class _ActivityCreateBusinessState extends State<activity_create_business> {
  final PageController _controller = PageController();
  int currentIndex = 0;
  bool isLoading = false;

  List<Categories_Model> _categories = [];
  List<String> _selectedKeywords = [];
  bool _loadingCats = true;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _openAtController = TextEditingController();
  final TextEditingController _closeAtController = TextEditingController();

  // Map
  final MapController _mapController = MapController();
  double _selectedLat = UserPosition.Loc_Lat;
  double _selectedLng = UserPosition.Loc_Lng;

  // Others
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  String _selectedLanguage = MyApp.language;

  final ImagePicker _picker = ImagePicker();

  Color get _primary => App_Colors.Theme_Color;
  Color get _bgCard => Theme.of(context).splashColor;
  Color get _bgPage => Theme.of(context).scaffoldBackgroundColor;
  Color get _textMain => Theme.of(context).unselectedWidgetColor;
  Color get _textSub => Theme.of(context).disabledColor;

  bool get isRtl {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == "fa" || lang == "ar";
  }
  
  TextAlign get _textAlign => isRtl ? TextAlign.right : TextAlign.left;

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

  bool _validateCurrentStep() {
    switch (currentIndex) {
      case 0:
        return _selectedImage != null;
      case 1:
        return _selectedKeywords.isNotEmpty;
      case 2:
        return _nameController.text.trim().isNotEmpty &&
            _bioController.text.trim().isNotEmpty &&
            _phoneController.text.trim().isNotEmpty;
      case 3:
        return _addressController.text.trim().isNotEmpty;
      case 4:
        return _openAtController.text.trim().isNotEmpty &&
            _closeAtController.text.trim().isNotEmpty;
      case 5:
        return true;
      default:
        return true;
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    setState(() {
      _selectedImage = image;
      _selectedImageBytes = bytes;
    });
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final theme = Theme.of(context);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
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
    setState(() => isLoading = true);

    final result = await api_business().CreateBusiness(
      context,
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      lat: _selectedLat.toString(),
      lng: _selectedLng.toString(),
      open_at: _openAtController.text.trim(),
      close_at: _closeAtController.text.trim(),
      language: _selectedLanguage,
      image: _selectedImage,
      keywords: _selectedKeywords.join(","),
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (result) {
      Navigator.pop(context, true);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
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
    _controller.dispose();
    _nameController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _openAtController.dispose();
    _closeAtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: _bgPage,
          body: Column(
            children: [
              TopBar(context, true),
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) => setState(() => currentIndex = index),
                  children: [
                    buildSlide(
                      icon: Icons.add_photo_alternate_outlined,
                      title: AppLocalizations.of(context)!.bu_tab_title_1,
                      desc: AppLocalizations.of(context)!.bu_tab_descr_1,
                      child: _buildImagePicker(),
                    ),
                    buildSlide(
                      icon: Icons.category_outlined,
                      title: AppLocalizations.of(context)!.bu_tab_title_2,
                      desc: AppLocalizations.of(context)!.bu_tab_descr_2,
                      child: _buildKeywordsStep(),
                    ),
                    buildSlide(
                      icon: Icons.store_outlined,
                      title: AppLocalizations.of(context)!.bu_tab_title_3,
                      desc: AppLocalizations.of(context)!.bu_tab_descr_3,
                      child: _buildInfoStep(),
                    ),
                    buildSlide(
                      icon: Icons.location_on_outlined,
                      title: AppLocalizations.of(context)!.bu_tab_title_4,
                      desc: AppLocalizations.of(context)!.bu_tab_descr_4,
                      child: _buildLocationStep(),
                    ),
                    buildSlide(
                      icon: Icons.access_time_outlined,
                      title: AppLocalizations.of(context)!.bu_tab_title_5,
                      desc: AppLocalizations.of(context)!.bu_tab_descr_5,
                      child: _buildHoursStep(),
                    ),
                    buildSlide(
                      icon: Icons.language_outlined,
                      title: AppLocalizations.of(context)!.bu_tab_title_6,
                      desc: AppLocalizations.of(context)!.bu_tab_descr_6,
                      child: _buildLanguageStep(),
                    ),
                  ],
                ),
              ),

              // Progress Dots
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    6,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: currentIndex == index ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: currentIndex == index ? _primary : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Button
              Container(
                margin: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                height: 50,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: _validateCurrentStep()
                          ? _primary
                          : _primary.withOpacity(0.4),
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                      if (!_validateCurrentStep()) return;
                      if (currentIndex == 5) {
                        _submit();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      currentIndex == 5
                          ? AppLocalizations.of(context)!.submit_bus
                          : AppLocalizations.of(context)!.continuee,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
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

  // ====================== Steps ======================
  Widget _buildKeywordsStep() {
    if (_loadingCats) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          AppLocalizations.of(context)!.category_not_found,
          style: TextStyle( fontSize: 13, color: _textSub),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._categories.map((root) => Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: PageStorageKey('cat_${root.id}'),
            tilePadding: EdgeInsets.zero,
            title: Text(
              root.title,
              style: TextStyle(
                
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textMain,
              ),
            ),
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: root.children.map((child) {
                  final selected = _selectedKeywords.contains(child.title);
                  return FilterChip(
                    label: Text(child.title, style: const TextStyle(fontSize: 12)),
                    selected: selected,
                    onSelected: (_) => _toggleKeyword(child.title),
                    selectedColor: _primary,
                    checkmarkColor: Colors.white,
                    backgroundColor: _bgPage,
                    side: BorderSide(
                      color: selected ? _primary : Theme.of(context).dividerColor,
                      width: 1,
                    ),
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
        )),

        if (_selectedKeywords.isNotEmpty) ...[
          const SizedBox(height: 12),
          Divider(color: Theme.of(context).dividerColor, height: 1),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.selected_category,
            style: TextStyle( fontSize: 12, fontWeight: FontWeight.w600, color: _textSub),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _selectedKeywords.map((kw) {
              return Chip(
                label: Text(kw, style: const TextStyle(fontSize: 12, color: Colors.white)),
                deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white),
                onDeleted: () => _toggleKeyword(kw),
                backgroundColor: _primary,
                deleteIconColor: Colors.white,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget buildSlide({
    required IconData icon,
    required String title,
    required String desc,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: _bgCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4))
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 40, color: _primary),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle( fontSize: 14, fontWeight: FontWeight.bold, color: _textMain),
                ),
                const SizedBox(height: 10),
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: TextStyle( fontSize: 11, color: _textSub, height: 1.6),
                ),
                const SizedBox(height: 24),
                child,
                const SizedBox(height: 20),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: _bgPage,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedImage != null ? _primary : Theme.of(context).dividerColor,
            width: 1.5,
          ),
        ),
        child: _selectedImageBytes != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 48, color: _textSub),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.select_image,
              style: TextStyle( fontSize: 13, color: _textSub),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoStep() {
    return Column(
      children: [
        _buildTextField(controller: _nameController, hint: AppLocalizations.of(context)!.bu_name, icon: Icons.store_outlined),
        const SizedBox(height: 12),
        _buildTextField(controller: _bioController, hint: AppLocalizations.of(context)!.dit, icon: Icons.description_outlined, maxLines: 3),
        const SizedBox(height: 12),
        _buildTextField(controller: _phoneController, hint: AppLocalizations.of(context)!.sample_phone, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
      ],
    );
  }

  Widget _buildLocationStep() {
    return Column(
      children: [
        _buildTextField(
          controller: _addressController,
          hint: AppLocalizations.of(context)!.address_fully,
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.swipe_map,
          style: TextStyle( fontSize: 13, color: _textSub),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.38,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: LatLng(_selectedLat, _selectedLng),
                    zoom: 15.5,
                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture && position.center != null) {
                        setState(() {
                          _selectedLat = position.center!.latitude;
                          _selectedLng = position.center!.longitude;
                        });
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: Server.Root_Address+'/tile/proxy.php?layer=standard&z={z}&x={x}&y={y}',
                      userAgentPackageName: 'ir.izino.bzhub',
                    ),
                  ],
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 22,right: 25),
                    child: _CenterPin(),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "${_selectedLat.toStringAsFixed(6)}, ${_selectedLng.toStringAsFixed(6)}",
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF22C55E), fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHoursStep() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _selectTime(_openAtController),
          child: _buildTextField(
            controller: _openAtController,
            hint: AppLocalizations.of(context)!.start_job,
            icon: Icons.access_time_outlined,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _selectTime(_closeAtController),
          child: _buildTextField(
            controller: _closeAtController,
            hint: AppLocalizations.of(context)!.end_job,
            icon: Icons.access_time_filled_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageStep() {
    return Column(
      children: _languages.map((lang) {
        final isSelected = _selectedLanguage == lang["code"];
        return GestureDetector(
          onTap: () => setState(() => _selectedLanguage = lang["code"]!),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? _primary.withOpacity(0.08) : _bgPage,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? _primary : Theme.of(context).dividerColor,
                width: 1.5,
              ),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textAlign: _textAlign,
      onChanged: (_) => setState(() {}),
      style: TextStyle( fontSize: 13, color: _textMain),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle( fontSize: 12, color: _textSub),
        prefixIcon: Icon(icon, size: 18, color: _textSub),
        filled: true,
        fillColor: _bgPage,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _primary, width: 1.5),
        ),
      ),
    );
  }
}

// ====================== Center Pin ======================
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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _bounce = Tween<double>(begin: 0, end: -8)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _shadow = Tween<double>(begin: 1.0, end: 0.6)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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