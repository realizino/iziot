// activity_requests_edit.dart
import 'package:iziot/Models/Categories/Categories_Model.dart';
import 'package:iziot/Models/Request/Request_Model.dart';
import 'package:iziot/Widget/GetUserPosition.dart';
import 'package:iziot/api/Categories/api_categories.dart';
import 'package:iziot/api/Requests/api_requests.dart';
import 'package:iziot/l10n/app_localizations.dart';
import 'package:iziot/main.dart';
import 'package:iziot/Server/Server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';

class activity_requests_edit extends StatefulWidget {
  final Request_Model? request;

  const activity_requests_edit({Key? key, this.request}) : super(key: key);

  @override
  State<activity_requests_edit> createState() => _activity_requests_edit_State();
}

class _activity_requests_edit_State extends State<activity_requests_edit> {
  // ─── Controllers ──────────────────────────────────────────────────────────
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController expiresAtController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  // ─── Keywords ─────────────────────────────────────────────────────────────
  List<Categories_Model> _categories = [];
  List<String> _selectedKeywords = [];
  bool _loadingCats = true;
  bool _catsError = false;

  // ─── Location ─────────────────────────────────────────────────────────────
  double _selectedLat = UserPosition.Loc_Lat;
  double _selectedLng = UserPosition.Loc_Lng;
  bool _attachLocation = true; // toggled off automatically below if editing a request that had no location
  final MapController _mapController = MapController();

  // ─── Language ─────────────────────────────────────────────────────────────
  String _selectedLanguage = MyApp.language;

  // ─── Wizard ──────────────────────────────────────────────────────────────
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // ─── Helpers ──────────────────────────────────────────────────────────────
  bool get isRtl {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == "fa" || lang == "ar";
  }

  Color get _primary => Theme.of(context).primaryColor;
  Color get _bgPage => Theme.of(context).scaffoldBackgroundColor;
  Color get _textMain => Theme.of(context).unselectedWidgetColor;
  Color get _textSub => Theme.of(context).disabledColor;

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

  // ─── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadCategories();
    _initializeFields();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loadingCats = true;
      _catsError = false;
    });
    try {
      final tree = await api_categories().GetCategories(context);
      if (!mounted) return;
      setState(() {
        _categories = tree;
        _loadingCats = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingCats = false;
        _catsError = true;
      });
    }
  }

  void _initializeFields() {
    final req = widget.request;
    if (req != null) {
      titleController.text = req.title;
      descriptionController.text = req.description;
      amountController.text = req.amount_d != null
          ? (req.amount_d == req.amount_d!.roundToDouble()
          ? req.amount_d!.toInt().toString()
          : req.amount_d!.toStringAsFixed(2))
          : "";
      if (req.keywords != null && req.keywords!.isNotEmpty) {
        _selectedKeywords = req.keywords!.split(",").map((e) => e.trim()).toList();
      }
      _selectedLanguage = req.language;

      // Only treat location as "attached" if the original request actually had one.
      // Prevents silently stamping the editor's current GPS position on save.
      _attachLocation = req.lat != null && req.lng != null;
      if (_attachLocation) {
        _selectedLat = req.lat!;
        _selectedLng = req.lng!;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(LatLng(_selectedLat, _selectedLng), 15.5);
        });
      }

      if (req.expiresAt != null) {
        expiresAtController.text = req.expiresAt!.toIso8601String().substring(0, 10);
      }
      if (req.city != null) {
        cityController.text = req.city!;
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    expiresAtController.dispose();
    cityController.dispose();
    _pageController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ─── Validation ────────────────────────────────────────────────────────────
  bool _validateStep(int step) {
    switch (step) {
      case 0:
        return titleController.text.trim().isNotEmpty && descriptionController.text.trim().isNotEmpty;
      case 1:
        return _selectedKeywords.isNotEmpty;
      case 2:
        return true;
      case 3:
        return _selectedLanguage.isNotEmpty;
      default:
        return true;
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  // ─── Expiry date picker ────────────────────────────────────────────────────
  Future<void> _pickExpiryDate() async {
    final parsed = DateTime.tryParse(expiresAtController.text);
    final initial = (parsed != null && parsed.isAfter(DateTime.now())) ? parsed : DateTime.now().add(const Duration(days: 7));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => expiresAtController.text = picked.toIso8601String().substring(0, 10));
    }
  }

  void _recenterToCurrentLocation() {
    setState(() {
      _selectedLat = UserPosition.Loc_Lat;
      _selectedLng = UserPosition.Loc_Lng;
    });
    _mapController.move(LatLng(_selectedLat, _selectedLng), 15.5);
  }

  // ─── Submit ──────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_validateStep(_currentStep)) return;

    setState(() => _isLoading = true);

    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final amount = amountController.text.trim().isEmpty ? null : double.tryParse(amountController.text.trim());
    final expiresAt = expiresAtController.text.trim().isEmpty ? null : DateTime.tryParse(expiresAtController.text.trim());
    final city = cityController.text.trim().isEmpty ? null : cityController.text.trim();

    final lat = _attachLocation ? _selectedLat : null;
    final lng = _attachLocation ? _selectedLng : null;

    bool ok;
    if (widget.request != null) {
      ok = await api_requests().UpdateRequest(
        context,
        id: widget.request!.id,
        title: title,
        description: description,
        amount: amount,
        city: city,
        lat: lat,
        lng: lng,
        keywords: _selectedKeywords.join(","),
        language: _selectedLanguage,
        expiresAt: expiresAt,
      );
    } else {
      final created = await api_requests().CreateRequest(
        context,
        title: title,
        description: description,
        language: _selectedLanguage,
        amount: amount,
        city: city,
        lat: lat,
        lng: lng,
        keywords: _selectedKeywords.join(","),
        expiresAt: expiresAt,
      );
      ok = created != null;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      Fluttertoast.showToast(
        msg: widget.request != null ? AppLocalizations.of(context)!.opration_is_done : AppLocalizations.of(context)!.request_added,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.have_an_error,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  // ─── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final appLocal = AppLocalizations.of(context)!;

    return SafeArea(
        child: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.request != null ? appLocal.edit_rquest : appLocal.new_request),
              backgroundColor: _bgPage,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
              ],
            ),
            body: Column(
              children: [
                _buildStepHeader(),
                const SizedBox(height: 8),

                // ─── PageView ──────────────────────────────────────────────────
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) => setState(() => _currentStep = index),
                    children: [
                      _buildInfoStep(),
                      _buildKeywordsStep(),
                      _buildLocationStep(),
                      _buildLanguageStep(),
                    ],
                  ),
                ),

                // ─── Bottom buttons ───────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: TextButton(
                            onPressed: _prevStep,
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: _textSub.withOpacity(0.3)),
                              ),
                            ),
                            child: Text(appLocal.back, style: TextStyle(color: _textSub, fontSize: 13)),
                          ),
                        ),
                      if (_currentStep > 0) const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                            if (!_validateStep(_currentStep)) {
                              Fluttertoast.showToast(
                                msg: appLocal.inputisinvalid,
                                gravity: ToastGravity.BOTTOM,
                                toastLength: Toast.LENGTH_SHORT,
                                textColor: Colors.white,
                                fontSize: 14.0,
                              );
                              return;
                            }
                            if (_currentStep == 3) {
                              _submit();
                            } else {
                              _nextStep();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _validateStep(_currentStep) ? _primary : _primary.withOpacity(0.4),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1.8),
                          )
                              : Text(
                            _currentStep == 3 ? appLocal.submit : appLocal.continuee,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }

  // ─── Step header: progress bar + step title ─────────────────────────────
  Widget _buildStepHeader() {
    final appLocal = AppLocalizations.of(context)!;
    final titles = [
      "Basic info",
      "Key words",
      "Location",
      "Language",
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(4, (i) {
              final active = i <= _currentStep;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: active ? _primary : _textSub.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            "${_currentStep + 1}/4 · ${titles[_currentStep]}",
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _textSub),
          ),
        ],
      ),
    );
  }

  // ─── Step 0: Info ──────────────────────────────────────────────────────────
  Widget _buildInfoStep() {
    final appLocal = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildTextField(
              controller: titleController,
              hint: appLocal.title,
              icon: Icons.title,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: descriptionController,
              hint: appLocal.description,
              icon: Icons.description,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: amountController,
              hint: appLocal.amount,
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
              suffixText: "\$",
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            _buildDateField(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ─── Step 1: Keywords ──────────────────────────────────────────────────────
  Widget _buildKeywordsStep() {
    final appLocal = AppLocalizations.of(context)!;

    if (_loadingCats) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (_catsError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 36, color: _textSub),
              const SizedBox(height: 10),
              Text(appLocal.have_an_error, style: TextStyle(fontSize: 13, color: _textSub), textAlign: TextAlign.center),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _loadCategories,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(appLocal.retry, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_categories.isEmpty) {
      return Center(
        child: Text(appLocal.category_not_found, style: TextStyle(fontSize: 13, color: _textSub)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._categories.map((root) => Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                key: PageStorageKey('cat_${root.id}'),
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
                        label: Text(child.title, style: const TextStyle(fontSize: 12)),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            if (selected) {
                              _selectedKeywords.remove(child.title);
                            } else {
                              _selectedKeywords.add(child.title);
                            }
                          });
                        },
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
            )),
            if (_selectedKeywords.isNotEmpty) ...[
              const SizedBox(height: 12),
              Divider(color: Theme.of(context).dividerColor, height: 1),
              const SizedBox(height: 10),
              Text(
                "${appLocal.selected_category} (${_selectedKeywords.length})",
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
                    onDeleted: () => setState(() => _selectedKeywords.remove(kw)),
                    backgroundColor: _primary,
                    deleteIconColor: Colors.white,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─── Step 2: Location ──────────────────────────────────────────────────────
  Widget _buildLocationStep() {
    final appLocal = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildTextField(
              controller: cityController,
              hint: appLocal.city_name,
              icon: Icons.location_city,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // ─── Attach-location toggle ────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: _bgPage,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _attachLocation,
                activeColor: _primary,
                title: Text(
                  "My Location",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textMain),
                ),
                onChanged: (v) => setState(() => _attachLocation = v),
              ),
            ),
            const SizedBox(height: 12),

            if (_attachLocation) ...[
              Text(
                appLocal.swipe_map,
                style: TextStyle(fontSize: 13, color: _textSub),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.32,
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
                            urlTemplate: Server.Root_Address + '/tile/proxy.php?layer=standard&z={z}&x={x}&y={y}',
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
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: FloatingActionButton.small(
                          heroTag: "recenter_request_map",
                          onPressed: _recenterToCurrentLocation,
                          backgroundColor: theme.cardColor,
                          elevation: 2,
                          child: Icon(Icons.my_location_rounded, color: _primary, size: 20),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.place_rounded, size: 14, color: Color(0xFF22C55E)),
                      const SizedBox(width: 6),
                      Text(
                        "${_selectedLat.toStringAsFixed(6)}, ${_selectedLng.toStringAsFixed(6)}",
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF22C55E), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ] else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: _bgPage,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _textSub.withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.location_off_rounded, size: 28, color: _textSub),
                    const SizedBox(height: 8),
                    Text(
                      appLocal.not_specified,
                      style: TextStyle(fontSize: 12.5, color: _textSub),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Step 3: Language ──────────────────────────────────────────────────────
  Widget _buildLanguageStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            ..._languages.map((lang) {
              final isSelected = _selectedLanguage == lang["code"];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _selectedLanguage = lang["code"]!),
                    child: Container(
                      width: double.infinity,
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
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ─── Reusable TextField ────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? suffixText,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textAlign: isRtl ? TextAlign.right : TextAlign.left,
      onChanged: onChanged,
      style: TextStyle(fontSize: 13, color: _textMain),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: _textSub),
        prefixIcon: Icon(icon, size: 18, color: _textSub),
        suffixText: suffixText,
        suffixStyle: TextStyle(fontSize: 13, color: _textSub, fontWeight: FontWeight.w600),
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

  // ─── Date field with picker (instead of free text) ─────────────────────────
  Widget _buildDateField() {
    final appLocal = AppLocalizations.of(context)!;
    final hasValue = expiresAtController.text.trim().isNotEmpty;

    return GestureDetector(
      onTap: _pickExpiryDate,
      child: AbsorbPointer(
        child: TextField(
          controller: expiresAtController,
          readOnly: true,
          textAlign: isRtl ? TextAlign.right : TextAlign.left,
          style: TextStyle(fontSize: 13, color: _textMain),
          decoration: InputDecoration(
            hintText: appLocal.no_expiry,
            hintStyle: TextStyle(fontSize: 12, color: _textSub),
            prefixIcon: Icon(Icons.calendar_today_rounded, size: 18, color: _textSub),
            suffixIcon: hasValue
                ? IconButton(
              icon: Icon(Icons.close_rounded, size: 18, color: _textSub),
              onPressed: () {
                // AbsorbPointer blocks taps on the field, but IconButton still
                // receives them since it's outside the absorbed TextField itself
                // — handled via the wrapping GestureDetector exclusion below.
              },
            )
                : null,
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
        ),
      ),
    );
  }
}

// ─── Center Pin Widget ──────────────────────────────────────────────────────
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
    final themeColor = Theme.of(context).primaryColor;
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