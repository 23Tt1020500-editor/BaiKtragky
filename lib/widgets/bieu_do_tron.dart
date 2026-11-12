import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/danh_muc.dart';

class BieuDoTron extends CustomPainter {
  final Map<String, double> data;
  final double tienDo;
  BieuDoTron(this.data, {this.tienDo = 1});

  @override
  void paint(Canvas canvas, Size size) {
    final tong = data.values.fold<double>(0, (s, v) => s + v);
    if (tong == 0) return;

    const doDay = 16.0;
    final rect = Rect.fromLTWH(
      doDay / 2,
      doDay / 2,
      size.width - doDay,
      size.height - doDay,
    );

    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = const Color(0xFFEEF2F4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = doDay,
    );

    var batDau = -math.pi / 2;
    const khoang = 0.05;

    data.forEach((ten, gia) {
      final goc = gia / tong * 2 * math.pi;
      final quet =
          (data.length == 1 ? goc - 0.001 : math.max(goc - khoang, 0.01)) *
          tienDo;
      if (quet > 0) {
        canvas.drawArc(
          rect,
          batDau + khoang / 2,
          quet,
          false,
          Paint()
            ..color = layDanhMuc(ten).mau
            ..style = PaintingStyle.stroke
            ..strokeWidth = doDay
            ..strokeCap = StrokeCap.round,
        );
      }
      batDau += goc;
    });
  }

  @override
  bool shouldRepaint(covariant BieuDoTron old) =>
      old.data != data || old.tienDo != tienDo;
}
