import 'dart:math';

import 'package:iziot/Data/Colors/App_Colors.dart';
import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/Screens/activity_splash.dart';
import 'package:iziot/api/ForgetPassword/api_forgetpassword.dart';
import 'package:iziot/api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../l10n/app_localizations.dart';

// ─── Brand colors ────────────────────────────────────────────────────────────
const _primary      = Color(0xFFD7561C);
const _primaryMuted = Color(0xFFEECDBC);
const _textMain     = Color(0xFF1C1C1E);
const _textSub      = Color(0xFF9A9A9A);
const _fieldBg      = Color(0xFFF2F2F2);
const _bgCard       = Color(0xFFFFFFFF);

class activity_forgetpassworddone extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => activity_forgetpassworddone_state();
}

class activity_forgetpassworddone_state extends State<activity_forgetpassworddone> {

  // ─── State ───────────────────────────────────────────────────────────────────
  bool submitLoading    = false;
  bool obscurePassword  = true;
  bool obscureRePassword = true;

  final TextEditingController passwordController   = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();

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

  TextStyle get _titleStyle    => TextStyle( fontSize: 22, fontWeight: FontWeight.w700, color: _textMain, height: 1.3);
  TextStyle get _subtitleStyle => TextStyle( fontSize: 13, color: _textSub, height: 1.5);
  TextStyle get _fieldStyle    => TextStyle( fontSize: 14, color: _textMain);
  TextStyle get _hintStyle     => TextStyle( fontSize: 13, color: _textSub);
  TextStyle get _btnStyle      => TextStyle( fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2);
  TextStyle get _linkStyle     => TextStyle( fontSize: 12, color: _textSub);

  // ─── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    final list = Strings.Config["background"].toString().split(",");
    backgroundImage = list[Random().nextInt(list.length)];
  }

  @override
  void dispose() {
    passwordController.dispose();
    rePasswordController.dispose();
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
              controller: passwordController,
              hint: AppLocalizations.of(context)!.password,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.next,
              suffix: _PasswordToggle(
                obscure: obscurePassword,
                onTap: () => setState(() => obscurePassword = !obscurePassword),
              ),
            ),
            const SizedBox(height: 10),
            _InputField(
              controller: rePasswordController,
              hint: AppLocalizations.of(context)!.configpassword,
              obscureText: obscureRePassword,
              textInputAction: TextInputAction.done,
              suffix: _PasswordToggle(
                obscure: obscureRePassword,
                onTap: () => setState(() => obscureRePassword = !obscureRePassword),
              ),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FormHeader(),
                    const SizedBox(height: 28),
                    _InputField(
                      controller: passwordController,
                      hint: AppLocalizations.of(context)!.password,
                      obscureText: obscurePassword,
                      textInputAction: TextInputAction.next,
                      suffix: _PasswordToggle(
                        obscure: obscurePassword,
                        onTap: () => setState(() => obscurePassword = !obscurePassword),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _InputField(
                      controller: rePasswordController,
                      hint: AppLocalizations.of(context)!.configpassword,
                      obscureText: obscureRePassword,
                      textInputAction: TextInputAction.done,
                      suffix: _PasswordToggle(
                        obscure: obscureRePassword,
                        onTap: () => setState(() => obscureRePassword = !obscureRePassword),
                      ),
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
        Text(AppLocalizations.of(context)!.submit, style: _titleStyle),
        const SizedBox(height: 4),
        Text(AppLocalizations.of(context)!.enter_the, style: _subtitleStyle),
      ],
    );
  }

  Widget _InputField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.next,
    Widget? suffix,
  }) {
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: TextField(
        controller: controller,
        style: _fieldStyle,
        keyboardType: TextInputType.visiblePassword,
        textInputAction: textInputAction,
        obscureText: obscureText,
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: _hintStyle,
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
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

  Widget _PasswordToggle({required bool obscure, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: _textSub,
          size: 18,
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

    final password   = passwordController.text.trim();
    final rePassword = rePasswordController.text.trim();

    if (password.isEmpty || rePassword.isEmpty || password != rePassword) {
      _showToast(AppLocalizations.of(context)!.pelasecheckinputs);
      return;
    }

    if (!_validatePassword(password)) {
      _showToast(AppLocalizations.of(context)!.pleaseentervalidpassword);
      return;
    }

    setState(() => submitLoading = true);
    await api_forgetpassword().GetForgetPasswordThree(context, password, rePassword);
    if (mounted) setState(() => submitLoading = false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => activity_splash_state()),
          (route) => false,
    );
  }

  void _showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: App_Colors.Red_Color,
      gravity: ToastGravity.BOTTOM,
      webPosition: "bottom",
      webBgColor: App_Colors.Red_String_Color,
      toastLength: Toast.LENGTH_SHORT,
      textColor: App_Colors.White_Color,
      fontSize: 16.0,
    );
  }

  bool _validatePassword(String value) {
    final pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    return RegExp(pattern).hasMatch(value);
  }
}