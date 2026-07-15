import 'package:iziot/Screens/User/activity_profile.dart';
import 'package:iziot/Widget/TopBar.dart';
import 'package:iziot/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../Data/Strings/Strings.dart';
import '../Server/Server.dart';

class activity_qr_scanner extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => activity_qr_scanner_state();
}

class activity_qr_scanner_state extends State<activity_qr_scanner>
    with TickerProviderStateMixin {
  late final MobileScannerController controller;
  bool OpenProfileActivity = false;

  // ─── Detected QR corners (in camera-preview coordinates) ─────────────────
  List<Offset>? _detectedCorners;
  Size? _previewSize;

  // ─── Scan-line animation (shown while no QR detected) ─────────────────────
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;

  // ─── QR-found animation: brackets snap onto the QR then fade ─────────────
  late AnimationController _foundController;
  late Animation<double> _foundScale;   // 1.15 → 1.0  (snap-in)
  late Animation<double> _foundOpacity; // 0 → 1 → 1 → 0

  // ─── Helpers ──────────────────────────────────────────────────────────────
  bool get isRtl {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == "fa" || lang == "ar";
  }

  static const Color _accent = Color(0xFF61a896); // BzHub orange

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();

    // Idle scan line
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );

    // QR-found feedback: scale 1.15→1.0 + opacity 0→1→1→fade
    _foundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _foundScale = Tween<double>(begin: 1.15, end: 1.0).animate(
      CurvedAnimation(
          parent: _foundController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _foundOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25),
    ]).animate(_foundController);
  }

  @override
  void dispose() {
    controller.dispose();
    _scanLineController.dispose();
    _foundController.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            TopBar(context, true),
            Expanded(
              child: Stack(
                children: [
                  // Camera feed — we need its rendered size for coordinate mapping
                  LayoutBuilder(builder: (context, constraints) {
                    _previewSize =
                        Size(constraints.maxWidth, constraints.maxHeight);
                    return MobileScanner(
                      controller: controller,
                      onDetect: _onDetect,
                      errorBuilder: (ctx, error, child) =>
                          _buildErrorState(ctx, error),
                    );
                  }),

                  // Dark overlay with square cutout (only when no QR locked)
                  if (_detectedCorners == null) const _ScannerOverlay(),

                  // Idle scan frame + line (hidden once QR found)
                  if (_detectedCorners == null)
                    Center(
                      child: AnimatedBuilder(
                        animation: _scanLineAnimation,
                        builder: (_, __) => _ScanFrame(
                          scanProgress: _scanLineAnimation.value,
                        ),
                      ),
                    ),

                  // ── iPhone-style: brackets track the actual QR ────────────
                  if (_detectedCorners != null && _previewSize != null)
                    AnimatedBuilder(
                      animation: _foundController,
                      builder: (_, __) {
                        return Opacity(
                          opacity: _foundOpacity.value,
                          child: Transform.scale(
                            scale: _foundScale.value,
                            child: CustomPaint(
                              painter: _QrTrackingPainter(
                                corners: _detectedCorners!,
                                color: _accent,
                              ),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        );
                      },
                    ),

                  // Bottom hint
                  if (_detectedCorners == null)
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          const Icon(Icons.qr_code_scanner,
                              color: Colors.white38, size: 20),
                          const SizedBox(height: 8),
                          Text(
                                'Point your camera at a BzHub QR code',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Error state ──────────────────────────────────────────────────────────
  Widget _buildErrorState(
      BuildContext context, MobileScannerException error) {
    final String message;
    if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
      message = AppLocalizations.of(context)!.camera_access;
    } else if (error.errorCode == MobileScannerErrorCode.unsupported) {
      message = AppLocalizations.of(context)!.camera_not_supported;
    } else {
      message = AppLocalizations.of(context)!.camera_not_access;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Image.asset("assets/icons/qr_code_error.png",
                  width: 80, color: Colors.white38),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: Colors.white60, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  // ─── QR detected ──────────────────────────────────────────────────────────
  void _onDetect(BarcodeCapture capture) {
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || OpenProfileActivity) return;

    final String? rawValue = barcode.rawValue;
    if (rawValue == null) return;

    // ── Map barcode corners from image coords → screen coords ──────────────
    final corners = barcode.corners; // List<Offset> in image-sensor space
    if (corners.isNotEmpty && _previewSize != null && capture.size != null) {
      final imageSize = capture.size!; // actual camera image resolution
      final screen = _previewSize!;

      // Scale factor: camera image → rendered preview (cover fit)
      final double scaleX = screen.width / imageSize.width;
      final double scaleY = screen.height / imageSize.height;

      final mapped = corners
          .map((c) => Offset(c.dx * scaleX, c.dy * scaleY))
          .toList();

      if (!OpenProfileActivity) {
        setState(() => _detectedCorners = mapped);
        _scanLineController.stop();
        _foundController.forward(from: 0);
      }
    }

    // ── Navigate after short visual feedback delay ─────────────────────────
    if (!OpenProfileActivity) {
      setState(() => OpenProfileActivity = true);

      final String URL = rawValue + "/";
      debugPrint("Qr code is : $URL");

      final List<String> parts = URL.split("/");
      debugPrint("Username is : ${parts.length > 4 ? parts[4] : ''}");

      String username =
      (parts.length > 4 && parts[4].isNotEmpty) ? parts[4] : rawValue;
      Strings.DeepLink = username;

      Future.delayed(const Duration(milliseconds: 550), () {
        if (!mounted) return;
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(builder: (_) => activity_display()),
        //       (route) => false,
        // );

      });
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Idle overlay: darkens everything except the centre square
// ═══════════════════════════════════════════════════════════════════════════════
class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OverlayPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double frameSize = 240;
    final double left = (size.width - frameSize) / 2;
    final double top = (size.height - frameSize) / 2;
    final Rect cut = Rect.fromLTWH(left, top, frameSize, frameSize);
    final paint = Paint()..color = Colors.black.withOpacity(0.62);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, cut.top), paint);
    canvas.drawRect(
        Rect.fromLTWH(0, cut.bottom, size.width, size.height - cut.bottom),
        paint);
    canvas.drawRect(Rect.fromLTWH(0, cut.top, cut.left, frameSize), paint);
    canvas.drawRect(
        Rect.fromLTWH(cut.right, cut.top, size.width - cut.right, frameSize),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// Idle scan frame: corner brackets + sweeping scan line
// ═══════════════════════════════════════════════════════════════════════════════
class _ScanFrame extends StatelessWidget {
  final double scanProgress;

  const _ScanFrame({required this.scanProgress});

  static const double _size = 240;
  static const Color _accent = Color(0xFF61a896);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        children: [
          // Corner brackets
          CustomPaint(
            painter: _CornerBracketsPainter(
              color: _accent,
              length: 28,
              thickness: 3.5,
              radius: 6,
            ),
            child: const SizedBox(width: _size, height: _size),
          ),

          // Sweep line
          Positioned(
            top: scanProgress * (_size - 2),
            left: 16,
            right: 16,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  _accent.withOpacity(0),
                  _accent.withOpacity(0.9),
                  _accent,
                  _accent.withOpacity(0.9),
                  _accent.withOpacity(0),
                ]),
                boxShadow: [
                  BoxShadow(
                      color: _accent.withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// iPhone-style: brackets that wrap around the DETECTED QR polygon
// ═══════════════════════════════════════════════════════════════════════════════
class _QrTrackingPainter extends CustomPainter {
  final List<Offset> corners; // 4 mapped screen-space corners
  final Color color;

  const _QrTrackingPainter({required this.corners, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (corners.length < 4) return;

    // corners order from mobile_scanner: TL, TR, BR, BL
    final tl = corners[0];
    final tr = corners[1];
    final br = corners[2];
    final bl = corners[3];

    // Expand slightly so brackets sit just outside the QR
    final center = Offset(
      (tl.dx + tr.dx + br.dx + bl.dx) / 4,
      (tl.dy + tr.dy + br.dy + bl.dy) / 4,
    );
    Offset expand(Offset p, double factor) =>
        Offset(center.dx + (p.dx - center.dx) * factor,
            center.dy + (p.dy - center.dy) * factor);

    final eTL = expand(tl, 1.08);
    final eTR = expand(tr, 1.08);
    final eBR = expand(br, 1.08);
    final eBL = expand(bl, 1.08);

    // Length of each bracket arm (~25% of QR side)
    final sideLen = (eTR - eTL).distance;
    final armLen = (sideLen * 0.25).clamp(16.0, 40.0);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Glow layer
    final glowPaint = Paint()
      ..color = color.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    void drawCorner(Offset vertex, Offset edgeA, Offset edgeB) {
      final dirA = (edgeA - vertex) / (edgeA - vertex).distance;
      final dirB = (edgeB - vertex) / (edgeB - vertex).distance;
      final path = Path()
        ..moveTo(vertex.dx + dirA.dx * armLen,
            vertex.dy + dirA.dy * armLen)
        ..lineTo(vertex.dx, vertex.dy)
        ..lineTo(vertex.dx + dirB.dx * armLen,
            vertex.dy + dirB.dy * armLen);
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, paint);
    }

    drawCorner(eTL, eTR, eBL);
    drawCorner(eTR, eTL, eBR);
    drawCorner(eBR, eTR, eBL);
    drawCorner(eBL, eTL, eBR);

    // Subtle fill tint over QR
    final fillPaint = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    final fillPath = Path()
      ..moveTo(eTL.dx, eTL.dy)
      ..lineTo(eTR.dx, eTR.dy)
      ..lineTo(eBR.dx, eBR.dy)
      ..lineTo(eBL.dx, eBL.dy)
      ..close();
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _QrTrackingPainter old) =>
      old.corners != corners || old.color != color;
}

// ─── Idle corner brackets painter ────────────────────────────────────────────
class _CornerBracketsPainter extends CustomPainter {
  final Color color;
  final double length;
  final double thickness;
  final double radius;

  const _CornerBracketsPainter({
    required this.color,
    required this.length,
    required this.thickness,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final l = length;
    final r = radius;

    // Top-left
    canvas.drawPath(
        Path()
          ..moveTo(0, l)
          ..lineTo(0, r)
          ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
          ..lineTo(l, 0),
        paint);

    // Top-right
    canvas.drawPath(
        Path()
          ..moveTo(w - l, 0)
          ..lineTo(w - r, 0)
          ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
          ..lineTo(w, l),
        paint);

    // Bottom-left
    canvas.drawPath(
        Path()
          ..moveTo(0, h - l)
          ..lineTo(0, h - r)
          ..arcToPoint(Offset(r, h), radius: Radius.circular(r))
          ..lineTo(l, h),
        paint);

    // Bottom-right
    canvas.drawPath(
        Path()
          ..moveTo(w - l, h)
          ..lineTo(w - r, h)
          ..arcToPoint(Offset(w, h - r), radius: Radius.circular(r))
          ..lineTo(w, h - l),
        paint);
  }

  @override
  bool shouldRepaint(covariant _CornerBracketsPainter old) =>
      old.color != color;
}