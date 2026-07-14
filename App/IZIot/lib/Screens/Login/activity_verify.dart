import 'dart:math';

import 'package:iziot/Data/Colors/App_Colors.dart';
import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/Screens/Login/activity_signup.dart';
import 'package:iziot/Screens/Login/activity_signupdone.dart';
import 'package:iziot/api/Login/api_login.dart';
import 'package:iziot/api/Signup/api_signup.dart';
import 'package:iziot/api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../l10n/app_localizations.dart';

// ─── Brand colors ────────────────────────────────────────────────────────────
const _primary      = Color(0xFFD7561C);
const _primaryMuted = Color(0xFFEECDBC);
const _textMain     = Color(0xFF1C1C1E);
const _textSub      = Color(0xFF9A9A9A);
const _bgCard       = Color(0xFFFFFFFF);

class activity_verify extends StatefulWidget {
  final String email;
  const activity_verify({Key? key, required this.email}) : super(key: key);

  @override
  State<StatefulWidget> createState() => activity_verify_state();
}

class activity_verify_state extends State<activity_verify> {

  // ─── State ───────────────────────────────────────────────────────────────────
  bool submitLoading = false;
  final TextEditingController pinController = TextEditingController();

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
    pinController.dispose();
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
        padding: const EdgeInsets.fromLTRB(50, 28, 50, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FormHeader(),
            const SizedBox(height: 32),
            _PinField(),
            const SizedBox(height: 24),
            _PrimaryBtn(
              label: AppLocalizations.of(context)!.verify,
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
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FormHeader(),
                    const SizedBox(height: 36),
                    _PinField(),
                    const SizedBox(height: 28),
                    _PrimaryBtn(
                      label: AppLocalizations.of(context)!.verify,
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
        Text(AppLocalizations.of(context)!.verify, style: _titleStyle),
        const SizedBox(height: 4),
        Text(AppLocalizations.of(context)!.enter_the, style: _subtitleStyle),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            style: _subtitleStyle,
            children: [
              TextSpan(
                text: widget.email,
                style: const TextStyle(
                  color: _primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _PinField() {
    return Center(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: PinCodeTextField(
          appContext: context,
          controller: pinController,
          length: 5,
          keyboardType: TextInputType.number,
          enablePinAutofill: true,
          textStyle: TextStyle(
            fontSize: 20,
            color: _textMain,
          ),
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(10),
            fieldHeight: 56,
            fieldWidth: 48,
            activeColor: _primary,
            activeFillColor: Colors.white,
            selectedColor: _primary,
            selectedFillColor: Colors.white,
            inactiveColor: Color(0xFFE0E0E0),
            inactiveFillColor: Color(0xFFF2F2F2),
            errorBorderColor: Colors.red,
            disabledColor: Colors.grey,
          ),
          enableActiveFill: true,
          animationType: AnimationType.scale,
          animationDuration: const Duration(milliseconds: 150),
          onChanged: (_) {},
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

    if (pinController.text.trim().isEmpty) {
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
    final result = await api_signup().GetCheckVerifyCode(context, pinController.text.trim());
    if (mounted) setState(() => submitLoading = false);

    if (result) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => activity_signupdone()),
            (route) => false,
      );
    } else {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.verifycodeisfalse,
        backgroundColor: App_Colors.Red_Color,
        gravity: ToastGravity.BOTTOM,
        webPosition: "bottom",
        webBgColor: App_Colors.Red_String_Color,
        toastLength: Toast.LENGTH_SHORT,
        textColor: App_Colors.White_Color,
        fontSize: 16.0,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => activity_signup()),
            (route) => false,
      );
    }
  }
}