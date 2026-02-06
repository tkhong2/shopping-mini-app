import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class GoMallFeaturesSection extends StatelessWidget {
  const GoMallFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Static "GoMall cam kết" label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A94FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.verified,
                  size: 16,
                  color: Color(0xFF1A94FF),
                ),
                SizedBox(width: 4),
                Text(
                  'GoMall cam kết',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A94FF),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Scrolling marquee text
          Expanded(
            child: SizedBox(
              height: 30,
              child: Marquee(
                text: '🚚 Freeship mọi đơn     🛡️ Hoàn 200% nếu hàng giả     🔄 30 ngày đổi trả     ⚡ Giao hàng nhanh chóng     ',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                scrollAxis: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.center,
                blankSpace: 50.0,
                velocity: 40.0,
                pauseAfterRound: const Duration(seconds: 1),
                startPadding: 0.0,
                accelerationDuration: const Duration(seconds: 1),
                accelerationCurve: Curves.linear,
                decelerationDuration: const Duration(milliseconds: 500),
                decelerationCurve: Curves.easeOut,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
