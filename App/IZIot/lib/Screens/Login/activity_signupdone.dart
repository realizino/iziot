import 'dart:math';

import 'package:iziot/Data/Colors/App_Colors.dart';
import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/Data_Storage/Data_Saver.dart';
import 'package:iziot/Screens/activity_splash.dart';
import 'package:iziot/api/Signup/api_signup.dart';
import 'package:iziot/api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../l10n/app_localizations.dart';

// ─── Brand colors ────────────────────────────────────────────────────────────
const _primary      = Color(0xFF61a896);
const _primaryMuted = Color(0xFFEECDBC);
const _textMain     = Color(0xFF1C1C1E);
const _textSub      = Color(0xFF9A9A9A);
const _fieldBg      = Color(0xFFF2F2F2);
const _bgCard       = Color(0xFFFFFFFF);

class activity_signupdone extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => activity_signupdone_state();
}

class activity_signupdone_state extends State<activity_signupdone> {

  // ─── State ───────────────────────────────────────────────────────────────────
  bool submitLoading = false;

  final TextEditingController nameController   = TextEditingController();
  final TextEditingController familyController = TextEditingController();
  final TextEditingController phoneController  = TextEditingController();
  final TextEditingController bioController    = TextEditingController();

  String backgroundImage = "";

  // ─── Helpers ─────────────────────────────────────────────────────────────────
  bool get isDesktop => MediaQuery.of(context).size.width >= 1024;
  bool get isMobile  => MediaQuery.of(context).size.width < 600;
  bool get isRtl {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == "fa" || lang == "ar";
  }

  double get contentMaxWidth => isDesktop ? 380 : 340;

  // ─── Typography ──────────────────────────────────────────────────────────────

  TextStyle get _titleStyle    => TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _textMain, height: 1.3);
  TextStyle get _subtitleStyle => TextStyle(fontSize: 13, color: _textSub, height: 1.5);
  TextStyle get _fieldStyle    => TextStyle(fontSize: 14, color: _textMain);
  TextStyle get _hintStyle     => TextStyle(fontSize: 13, color: _textSub);
  TextStyle get _btnStyle      => TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2);

  // ─── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    final list = Strings.Config["background"].toString().split(",");
    backgroundImage = list[Random().nextInt(list.length)];
  }

  @override
  void dispose() {
    nameController.dispose();
    familyController.dispose();
    phoneController.dispose();
    bioController.dispose();
    super.dispose();
  }

  // ─── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      backgroundColor: _bgCard,
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  // ─── Mobile ──────────────────────────────────────────────────────────────────
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MobileHero(),
          _MobileForm(),
        ],
      ),
    );
  }

  Widget _MobileHero() {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.45,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            backgroundImage,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: _primary),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.5, 1.0],
                colors: [Colors.transparent, Color(0x88000000)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _MobileForm() {
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FormHeader(),
            const SizedBox(height: 24),
            _InputField(
              controller: nameController,
              hint: AppLocalizations.of(context)!.name,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 10),
            _InputField(
              controller: familyController,
              hint: AppLocalizations.of(context)!.family,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 10),
            _InputField(
              controller: phoneController,
              hint: AppLocalizations.of(context)!.phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 10),
            _InputField(
              controller: bioController,
              hint: AppLocalizations.of(context)!.bio,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              maxLines: 3,
            ),
            const SizedBox(height: 18),
            _PrimaryBtn(
              label: AppLocalizations.of(context)!.submit,
              loading: submitLoading,
              onTap: () => _submitEvent(context),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Desktop ─────────────────────────────────────────────────────────────────
  Widget _buildDesktopLayout() {
    final imagePanel = Expanded(
      flex: isDesktop ? 3 : 2,
      child: SizedBox.expand(
        child: Image.network(
          backgroundImage,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) =>
          progress == null ? child : Container(color: _primaryMuted),
          errorBuilder: (_, __, ___) => Container(color: _primary),
        ),
      ),
    );

    final formPanel = Expanded(
      flex: 2,
      child: Container(
        color: _bgCard,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentMaxWidth),
            child: Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FormHeader(),
                    const SizedBox(height: 28),
                    _InputField(
                      controller: nameController,
                      hint: AppLocalizations.of(context)!.name,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 10),
                    _InputField(
                      controller: familyController,
                      hint: AppLocalizations.of(context)!.family,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 10),
                    _InputField(
                      controller: phoneController,
                      hint: AppLocalizations.of(context)!.phone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 10),
                    _InputField(
                      controller: bioController,
                      hint: AppLocalizations.of(context)!.bio,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 18),
                    _PrimaryBtn(
                      label: AppLocalizations.of(context)!.submit,
                      loading: submitLoading,
                      onTap: () => _submitEvent(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Row(
      children: [formPanel, imagePanel],
    );
  }

  // ─── Shared widgets ───────────────────────────────────────────────────────────

  Widget _FormHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.signup, style: _titleStyle),
        const SizedBox(height: 4),
        Text(AppLocalizations.of(context)!.enter_the, style: _subtitleStyle),
      ],
    );
  }

  Widget _InputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    int maxLines = 1,
  }) {
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: TextField(
        controller: controller,
        style: _fieldStyle,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: _hintStyle,
          contentPadding: EdgeInsets.symmetric(
            vertical: maxLines > 1 ? 14 : 13,
            horizontal: 16,
          ),
          fillColor: _fieldBg,
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
            borderSide: const BorderSide(color: _primary, width: 1.4),
          ),
        ),
      ),
    );
  }

  Widget _PrimaryBtn({
    required String label,
    required VoidCallback onTap,
    bool loading = false,
  }) {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          disabledBackgroundColor: _primaryMuted,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: loading
            ? const SizedBox(
          width: 18, height: 18,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1.8),
        )
            : Text(label, style: _btnStyle.copyWith(color: Colors.white)),
      ),
    );
  }

  // ─── Events ───────────────────────────────────────────────────────────────────

  Future<void> _submitEvent(BuildContext context) async {
    if (submitLoading) return;

    final name   = nameController.text.trim();
    final family = familyController.text.trim();
    final phone  = phoneController.text.trim();
    final bio    = bioController.text.trim();

    if (name.isEmpty || family.isEmpty || phone.isEmpty || bio.isEmpty) {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.pleasefillallfeilds,
        backgroundColor: App_Colors.Red_Color,
        gravity: ToastGravity.BOTTOM,
        webPosition: "bottom",
        webBgColor: App_Colors.Red_String_Color,
        toastLength: Toast.LENGTH_SHORT,
        textColor: App_Colors.White_Color,
        fontSize: 16.0,
      );
      return;
    }

    setState(() => submitLoading = true);
    final result = await api_signup().Signupdone(context, name, family, bio, phone);
    if (mounted) setState(() => submitLoading = false);

    if (result) {
      Data_Sever.Save_Data("tk", Strings.UT_Token);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => activity_splash_state()),
            (route) => false,
      );
    }
  }
}