import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'screens/man_hinh_chi_tieu.dart';
import 'utils/mau_sac.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  databaseFactory = databaseFactoryFfiWeb;

  runApp(const UngDungQuanLyChiTieu());
}

class UngDungQuanLyChiTieu extends StatelessWidget {
  const UngDungQuanLyChiTieu({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quản lý chi tiêu',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: MauSac.xanhNhat,
        scaffoldBackgroundColor: MauSac.nen,
      ),
      // Trên màn hình rộng (Chrome) thì co lại thành khung điện thoại
      builder: (context, child) => ColoredBox(
        color: const Color(0xFFDDE5E8),
        child: LayoutBuilder(
          builder: (context, box) => Center(
            child: SizedBox(
              width: box.maxWidth > 520 ? 520 : box.maxWidth,
              height: box.maxHeight,
              child: ClipRect(child: child),
            ),
          ),
        ),
      ),
      home: const ManHinhChiTieu(),
    );
  }
}
