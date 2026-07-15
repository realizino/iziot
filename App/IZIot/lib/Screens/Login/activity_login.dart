import 'dart:async';
import 'dart:math';

import 'package:iziot/Data/Colors/App_Colors.dart';
import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/Data_Storage/Data_Saver.dart';
import 'package:iziot/Screens/Login/activity_forgetpassword.dart';
import 'package:iziot/Screens/Login/activity_signup.dart';
import 'package:iziot/api/Login/api_login.dart';
import 'package:iziot/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../Services/Google/GoogleAuthService.dart';
import '../../l10n/app_localizations.dart';

// ─── Brand colors ─────────────────────────────────────────────────────────────
const _primary      = Color(0xff61a896);
const _primaryMuted = Color(0xffaeefe0);
const _textMain     = Color(0xFF1C1C1E);
const _textSub      = Color(0xFF9A9A9A);
const _fieldBg      = Color(0xFFF2F2F2);
const _bgCard       = Color(0xFFFFFFFF);

class activity_login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => activity_login_state();
}

class activity_login_state extends State<activity_login> {

  // ─── State ────────────────────────────────────────────────────────────────────
  bool loginLoading    = false;
  bool googleLoading   = false;
  bool obscurePassword = true;

  StreamSubscription? _authSub;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GoogleAuthService _googleAuth = GoogleAuthService();

  String backgroundImage = "";

  // ─── Helpers ──────────────────────────────────────────────────────────────────
  bool get isDesktop => MediaQuery.of(context).size.width >= 1024;
  bool get isMobile  => MediaQuery.of(context).size.width < 600;
  bool get isRtl {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == "fa" || lang == "ar";
  }

  double get contentMaxWidth => isDesktop ? 380 : 340;

  // ─── Typography ───────────────────────────────────────────────────────────────

  TextStyle get _titleStyle    => TextStyle( fontSize: 22, fontWeight: FontWeight.w700, color: _textMain, height: 1.3);
  TextStyle get _subtitleStyle => TextStyle( fontSize: 13, color: _textSub, height: 1.5);
  TextStyle get _fieldStyle    => TextStyle( fontSize: 14, color: _textMain);
  TextStyle get _hintStyle     => TextStyle( fontSize: 13, color: _textSub);
  TextStyle get _btnStyle      => TextStyle( fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2);
  TextStyle get _linkStyle     => TextStyle( fontSize: 12, color: _textSub);

  // ─── Lifecycle ────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    final list = Strings.Config["background"].toString().split(",");
    backgroundImage = list[Random().nextInt(list.length)];
  }

  @override
  void dispose() {
    _authSub?.cancel();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────────
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

  // ─── Mobile layout ────────────────────────────────────────────────────────────
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
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: _LanguageButton(overlay: true),
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
              controller: usernameController,
              hint: AppLocalizations.of(context)!.username,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 10),
            _InputField(
              controller: passwordController,
              hint: AppLocalizations.of(context)!.password,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              obscureText: obscurePassword,
              suffix: _PasswordToggle(),
            ),
            Align(
              alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => activity_forgetpassword())),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppLocalizations.of(context)!.forgetpassword,
                  style: _linkStyle.copyWith(color: _primary, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _PrimaryBtn(
              label: AppLocalizations.of(context)!.login,
              loading: loginLoading,
              onTap: () => _loginEvent(context),
            ),
            const SizedBox(height: 20),
            _SignupRow(),
          ],
        ),
      ),
    );
  }

  // ─── Desktop layout ───────────────────────────────────────────────────────────
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
        child: Stack(
          children: [
            Positioned(
              top: 20,
              right: 20,
              child: _LanguageButton(overlay: false),
            ),
            Center(
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
                          controller: usernameController,
                          hint: AppLocalizations.of(context)!.username,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 10),
                        _InputField(
                          controller: passwordController,
                          hint: AppLocalizations.of(context)!.password,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          obscureText: obscurePassword,
                          suffix: _PasswordToggle(),
                        ),
                        Align(
                          alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => activity_forgetpassword())),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.forgetpassword,
                              style: _linkStyle.copyWith(color: _primary, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _PrimaryBtn(
                          label: AppLocalizations.of(context)!.login,
                          loading: loginLoading,
                          onTap: () => _loginEvent(context),
                        ),
                        const SizedBox(height: 20),
                        _SignupRow(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
        Text(AppLocalizations.of(context)!.login, style: _titleStyle),
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
    bool obscureText = false,
    Widget? suffix,
  }) {
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: TextField(
        controller: controller,
        style: _fieldStyle,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        enableSuggestions: !obscureText,
        autocorrect: !obscureText,
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

  Widget _PasswordToggle() {
    return GestureDetector(
      onTap: () => setState(() => obscurePassword = !obscurePassword),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Icon(
          obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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


  Widget _SignupRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)!.donthaveaccount,
          style: _linkStyle,
        ),
        const SizedBox(width: 3),
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => activity_signup())),
          child: Text(
            AppLocalizations.of(context)!.signup,
            style: _linkStyle.copyWith(color: _primary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // ─── Language switcher ─────────────────────────────────────────────────────────

  /// Small pill button (globe icon + current language code).
  /// [overlay] = true → used on top of the hero image (translucent dark bg, white text).
  /// [overlay] = false → used on a plain background (light gray bg, dark text).
  Widget _LanguageButton({bool overlay = false}) {
    final Color bg = overlay ? Colors.black.withOpacity(0.28) : _fieldBg;
    final Color fg = overlay ? Colors.white : _textMain;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _showLanguageDialog,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language, size: 16, color: fg),
              const SizedBox(width: 4),
              Text(
                Strings.language.toUpperCase(),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLanguageDialog() {
    return showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: const EdgeInsets.all(0),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _bgCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                _languageItem(ctx, "English", "en", "assets/Images/USA_Flag.png"),
                _languageItem(ctx, "Persian", "fa", "assets/Images/Iran_Flag.png"),
                _languageItem(ctx, "Turkish", "tr", "assets/Images/Turk_Flag.png"),
                _languageItem(ctx, "Arabic", "ar", "assets/Images/Arab_Flag.png"),
                _languageItem(ctx, "French", "fr", "assets/Images/Franc_Flag.png"),
                _languageItem(ctx, "Spanish", "es", "assets/Images/Snain_Flag.png"),
                _languageItem(ctx, "Russian", "ru", "assets/Images/Russia_Flag.png"),
                _languageItem(ctx, "Chinese", "zh", "assets/Images/China_Flag.png"),
                _languageItem(ctx, "Italian", "it", "assets/Images/Italya_Flag.png"),
                _languageItem(ctx, "German", "de", "assets/Images/German_Flag.png"),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _languageItem(BuildContext ctx, String label, String code, String flagAsset) {
    final bool selected = Strings.language == code;
    return TextButton(
      onPressed: () => _changeLanguage(ctx, code),
      child: SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(label, style: const TextStyle(color: _textMain, fontSize: 16)),
                if (selected) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle, color: _primary, size: 18),
                ],
              ],
            ),
            Image.asset(flagAsset, width: 30),
          ],
        ),
      ),
    );
  }

  void _changeLanguage(BuildContext ctx, String code) {
    Data_Sever.Save_Data("language", code);
    Strings.language = code;
    MyApp.language = code;
    Navigator.pop(ctx);

    // The root MaterialApp builds its Locale from MyApp.language but doesn't
    // listen for changes by itself, so we trigger its setState here to make
    // the new locale apply immediately, without requiring an app restart.
    context.findAncestorStateOfType<MyApp>()?.setState(() {});

    if (mounted) setState(() {});
  }

  // ─── Events ───────────────────────────────────────────────────────────────────

  /// Username/password login event
  Future<void> _loginEvent(BuildContext context) async {
    if (loginLoading) return;

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isNotEmpty && password.isNotEmpty) {
      setState(() => loginLoading = true);
      await api_login().GetLogin(context, username, password);
      if (mounted) setState(() => loginLoading = false);
    } else {
      _showErrorToast(AppLocalizations.of(context)!.pleasefillallfeilds);
    }
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: App_Colors.Red_Color,
      gravity: ToastGravity.BOTTOM,
      webPosition: "bottom",
      webBgColor: App_Colors.Red_String_Color,
      toastLength: Toast.LENGTH_SHORT,
      textColor: App_Colors.White_Color,
      fontSize: 16.0,
    );
  }
}