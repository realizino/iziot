import 'dart:io';

import 'package:iziot/Data/Colors/App_Colors.dart';
import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/Models/Categories/Categories_Model.dart';
import 'package:iziot/Server/Server.dart';
import 'package:iziot/Widget/TopBar.dart';
import 'package:iziot/api/User/api_user.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';

class activity_profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => activity_profile_state();
}

class activity_profile_state extends State<activity_profile> {
  // ─── Theme shortcuts ──────────────────────────────────────────────────────────
  Color get _primary  => App_Colors.Theme_Color;
  Color get _bgCard   => Theme.of(context).splashColor;
  Color get _bgPage   => Theme.of(context).scaffoldBackgroundColor;
  Color get _textMain => Theme.of(context).unselectedWidgetColor;
  Color get _textSub  => Theme.of(context).disabledColor;

  // ─── Helpers ─────────────────────────────────────────────────────────────────
  bool get isRtl {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == "fa" || lang == "ar";
  }

  // ─── Controllers ─────────────────────────────────────────────────────────────
  final _bioController         = TextEditingController();
  final _passwordController    = TextEditingController();
  final _rePasswordController  = TextEditingController();

  bool _obscurePass   = true;
  bool _obscureRePass = true;
  bool _isSubmitting  = false;
  bool _isUploading   = false;

  // ─── Categories ──────────────────────────────────────────────────────────────
  bool _loadingCats        = true;
  List<Categories_Model> _categories  = [];
  List<String> _selectedKeywords      = [];

  // ─── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _bioController.text = Strings.UserData.bio;
  }

  @override
  void dispose() {
    _bioController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
    super.dispose();
  }



  // ─── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: _bgPage,
          body: SingleChildScrollView(
            child: Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TopBar(context, true),
                  _AvatarCard(),
                  const SizedBox(height: 12),
                  _InfoCard(),
                  const SizedBox(height: 12),
                  _PasswordCard(),
                  const SizedBox(height: 12),
                  _CategoriesCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _BottomBar(),
        )
    );
  }

  // ─── Avatar card ─────────────────────────────────────────────────────────────
  Widget _AvatarCard() {
    final imageUrl = (Strings.ProfileImage.isEmpty)
        ? Server.Root_Address+"/User/images/user.png"
        : Server.Root_Address+"/File/${Strings.ProfileImage}";

    return Container(
      margin: EdgeInsets.only(top: 16,right: 16,left: 16,bottom: 10),
      child: _Card(
        child: Column(
          children: [
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickAndUploadImage,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _primary.withOpacity(0.2), width: 3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: _isUploading
                          ? Container(
                        width: 90, height: 90,
                        color: _bgPage,
                        child: Center(
                          child: CircularProgressIndicator(
                              color: _primary, strokeWidth: 2),
                        ),
                      )
                          : Image.network(imageUrl,
                          width: 90, height: 90, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: _primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: _bgCard, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "${Strings.UserData.name} ${Strings.UserData.family}",
              style: TextStyle(
                
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textMain,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "@${Strings.UserData.username}",
              style: TextStyle( fontSize: 12, color: _textSub),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─── Info card (bio) ─────────────────────────────────────────────────────────
  Widget _InfoCard() {
    return Container(
      margin: EdgeInsets.only(top: 6,right: 16,left: 16,bottom: 10),
      child: _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(AppLocalizations.of(context)!.bio),
            const SizedBox(height: 10),
            _Field(
              controller: _bioController,
              hint: AppLocalizations.of(context)!.bio,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Password card ───────────────────────────────────────────────────────────
  Widget _PasswordCard() {
    return Container(
      margin: EdgeInsets.only(top: 16,right: 16,left: 16,bottom: 10),
      child: _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(AppLocalizations.of(context)!.password),
            const SizedBox(height: 10),
            _Field(
              controller: _passwordController,
              hint: AppLocalizations.of(context)!.password,
              obscureText: _obscurePass,
              suffix: _EyeToggle(
                obscure: _obscurePass,
                onTap: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
            const SizedBox(height: 10),
            _Field(
              controller: _rePasswordController,
              hint: AppLocalizations.of(context)!.configpassword,
              obscureText: _obscureRePass,
              suffix: _EyeToggle(
                obscure: _obscureRePass,
                onTap: () => setState(() => _obscureRePass = !_obscureRePass),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Categories card ─────────────────────────────────────────────────────────
  Widget _CategoriesCard() {
    return Container(
      margin: EdgeInsets.only(top: 16,right: 16,left: 16,bottom: 10),
      child: _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(AppLocalizations.of(context)!.categories),
            const SizedBox(height: 10),

            if (_loadingCats)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: _primary, strokeWidth: 2),
                ),
              )
            else if (_categories.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  AppLocalizations.of(context)!.noCategoriesAvailable,
                  style: TextStyle( fontSize: 13, color: _textSub),
                ),
              )
            else
              ..._categories.map((root) => _buildRootCategory(root)),

            if (_selectedKeywords.isNotEmpty) ...[
              const SizedBox(height: 12),
              Divider(color: _bgPage, height: 1),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(context)!.yourSelectedKeywords,
                style: TextStyle(
                   fontSize: 12,
                  fontWeight: FontWeight.w600, color: _textSub,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6, runSpacing: 6,
                children: _selectedKeywords.map((kw) => Chip(
                  label: Text(kw,
                      style: TextStyle( fontSize: 12, color: Colors.white)),
                  deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white),
                  onDeleted: () => _toggleKeyword(kw),
                  backgroundColor: _primary,   // ← نارنجی پررنگ
                  deleteIconColor: Colors.white,
                  side: BorderSide.none,
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRootCategory(Categories_Model root) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: PageStorageKey('cat_${root.id}'),
        tilePadding: EdgeInsets.zero,
        title: Text(
          root.title,
          style: TextStyle(
             fontSize: 14,
            fontWeight: FontWeight.w600, color: _textMain,
          ),
        ),
        children: [
          Wrap(
            spacing: 6, runSpacing: 6,
            children: root.children.map((child) {
              final selected = _selectedKeywords.contains(child.title);
              return FilterChip(
                label: Text(child.title,
                    style: TextStyle( fontSize: 12)),
                selected: selected,
                onSelected: (_) => _toggleKeyword(child.title),
                selectedColor: _primary,   // ← نارنجی پررنگ برای حالت انتخاب
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: selected ? _primary : _textSub,   // ← حاشیه به جای طوسی، رنگ متن
                  width: 1,
                ),
                backgroundColor: _bgCard,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : _textSub,   // ← متن سفید در حالت انتخاب
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _toggleKeyword(String title) {
    if (!mounted) return;
    setState(() {
      _selectedKeywords.contains(title)
          ? _selectedKeywords.remove(title)
          : _selectedKeywords.add(title);
    });
  }

  // ─── Bottom bar ───────────────────────────────────────────────────────────────
  Widget _BottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0XFFd7561c),
              disabledBackgroundColor: _primary.withOpacity(0.4),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSubmitting
                ? const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            )
                : Text(
              AppLocalizations.of(context)!.submit,
              style: TextStyle(
                 fontSize: 15,
                fontWeight: FontWeight.w600, color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Reusable widgets ────────────────────────────────────────────────────────
  Widget _Card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }

  Widget _SectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
         fontSize: 13,
        fontWeight: FontWeight.w700, color: _textSub,
      ),
    );
  }

  Widget _Field({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    int maxLines = 1,
    Widget? suffix,
  }) {
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        maxLines: obscureText ? 1 : maxLines,
        enableSuggestions: !obscureText,
        autocorrect: !obscureText,
        style: TextStyle( fontSize: 14, color: _textMain),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle( fontSize: 13, color: _textSub),
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
          fillColor: _bgPage,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _primary, width: 1.4),
          ),
        ),
      ),
    );
  }

  Widget _EyeToggle({required bool obscure, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: _textSub, size: 18,
        ),
      ),
    );
  }

  // ─── Logic ───────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      await api_user().AddNewBio(context, _bioController.text.trim());

      if (_passwordController.text.isNotEmpty) {
        if (_passwordController.text != _rePasswordController.text) {
          _toast(AppLocalizations.of(context)!.thepassisnot, error: true);
          return;
        }
        if (!_validatePassword(_passwordController.text)) {
          _toast(AppLocalizations.of(context)!.pleaseentervalidpassword, error: true);
          return;
        }
        await api_user().AddNewPassword(context, _passwordController.text);
      }

      _passwordController.clear();
      _rePasswordController.clear();

      _toast(AppLocalizations.of(context)!.opration_is_done, error: false);
    } catch (e) {
      _toast(AppLocalizations.of(context)!.error_in_save, error: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img == null) return;
    setState(() => _isUploading = true);
    try {
      await api_user().UploadNewAvatar(context, img.path);
    } catch (_) {
      _toast(AppLocalizations.of(context)!.error_in_upload, error: true);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _toast(String msg, {required bool error}) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: error ? App_Colors.Red_Color : App_Colors.Green_Color,
      textColor: Colors.white,
      fontSize: 14.0,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  bool _validatePassword(String v) =>
      RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
          .hasMatch(v);
}