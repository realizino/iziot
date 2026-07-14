import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Data/Colors/App_Colors.dart';

void _showPaymentSuccess(BuildContext context) {
  if (context == null) return;

  var refId = null;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: App_Colors.White_Color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_outline, color: Colors.white, size: 64),
          ),
          SizedBox(height: 24),
          Text(
            'پرداخت موفق! 🎉',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Vazir', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
          ),
          SizedBox(height: 12),
          Text(
            'اشتراک شما با موفقیت فعال شد',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Vazir', fontSize: 14, color: Color(0xFF6B7280)),
          ),
          if (refId != null && refId.isNotEmpty) ...[
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Text('شماره پیگیری', style: TextStyle(fontFamily: 'Vazir', fontSize: 12, color: Color(0xFF6B7280))),
                  SizedBox(height: 6),
                  Text(refId, style: TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                ],
              ),
            ),
          ],
          SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Color(0xFF10B981).withOpacity(0.3), blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context, true);
                },
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Text('عالیه!', style: TextStyle(fontFamily: 'Vazir', color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}