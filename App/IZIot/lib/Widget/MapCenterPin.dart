import 'package:flutter/material.dart';

class MapCenterPin extends StatefulWidget {
  const MapCenterPin({Key? key}) : super(key: key);

  @override
  State<MapCenterPin> createState() => _MapCenterPinState();
}

class _MapCenterPinState extends State<MapCenterPin> with SingleTickerProviderStateMixin {
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