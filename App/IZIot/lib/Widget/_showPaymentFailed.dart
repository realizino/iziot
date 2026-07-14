import 'package:flutter/material.dart';

import '../Data/Colors/App_Colors.dart';

void _showPaymentFailed(BuildContext context) {
  if (context == null) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: App_Colors.White_Color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.close_rounded, color: Colors.white, size: 64),
          ),
          SizedBox(height: 24),
          Text(
            'پرداخت ناموفق',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Vazir', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
          ),
          SizedBox(height: 12),
          Text(
            'متأسفانه پرداخت شما با مشکل مواجه شد',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Vazir', fontSize: 14, color: Color(0xFF6B7280)),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFF59E0B), width: 1),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'در صورت کسر موجودی، حداکثر ۷۲ ساعت صبر کنید. اگر برگشت نخورد با پشتیبانی تماس بگیرید.',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontFamily: 'Vazir', fontSize: 12, color: Color(0xFF92400E), height: 1.6),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(dialogContext);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('بستن', style: TextStyle(fontFamily: 'Vazir', color: Color(0xFF6B7280), fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    ),
  );
}