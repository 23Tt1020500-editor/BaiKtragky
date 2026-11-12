import 'package:flutter/material.dart';

import '../models/danh_muc.dart';
import '../utils/dinh_dang.dart';
import '../utils/mau_sac.dart';
import 'bieu_do_tron.dart';

/// Thẻ trắng chứa biểu đồ tròn + chú thích từng danh mục.
class TheBieuDo extends StatelessWidget {
  final Map<String, double> data;
  final double tong;
  const TheBieuDo({super.key, required this.data, required this.tong});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: MauSac.xanhDam.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: data.isEmpty
          ? const SizedBox(
              height: 84,
              child: Center(
                child: Text(
                  'Tháng này chưa có khoản chi nào',
                  style: TextStyle(color: MauSac.phu),
                ),
              ),
            )
          : Row(
              children: [
                SizedBox(
                  width: 124,
                  height: 124,
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey(
                      data.entries.map((e) => '${e.key}${e.value}').join(),
                    ),
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, t, _) => CustomPaint(
                      painter: BieuDoTron(data, tienDo: t),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${data.length}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: MauSac.chu,
                              ),
                            ),
                            const Text(
                              'danh mục',
                              style: TextStyle(fontSize: 11, color: MauSac.phu),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    children: data.entries.take(4).map((e) {
                      final dm = layDanhMuc(e.key);
                      final pt = tong == 0 ? 0 : e.value / tong;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: dm.mau,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.key,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: MauSac.chu,
                                    ),
                                  ),
                                  Text(
                                    dinhDangVnd(e.value),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: MauSac.phu,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${(pt * 100).round()}%',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: MauSac.chu,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
