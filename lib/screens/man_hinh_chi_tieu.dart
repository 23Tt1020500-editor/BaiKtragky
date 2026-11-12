import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/co_so_du_lieu.dart';
import '../models/chi_tieu.dart';
import '../models/danh_muc.dart';
import '../utils/dinh_dang.dart';
import '../utils/mau_sac.dart';
import '../widgets/dong_chi_tieu.dart';
import '../widgets/form_chi_tieu.dart';
import '../widgets/the_bieu_do.dart';

class ManHinhChiTieu extends StatefulWidget {
  const ManHinhChiTieu({super.key});

  @override
  State<ManHinhChiTieu> createState() => _ManHinhChiTieuState();
}

class _ManHinhChiTieuState extends State<ManHinhChiTieu> {
  List<ChiTieu> _tatCa = [];
  DateTime _thang = DateTime(DateTime.now().year, DateTime.now().month);
  String? _loc; // null = tất cả
  bool _dangTai = true;

  @override
  void initState() {
    super.initState();
    _tai();
  }

  Future<void> _tai() async {
    final data = await CoSoDuLieu.layTatCa();
    if (!mounted) return;
    setState(() {
      _tatCa = data;
      _dangTai = false;
    });
  }

  List<ChiTieu> get _trongThang => _tatCa
      .where((e) => e.ngay.year == _thang.year && e.ngay.month == _thang.month)
      .toList();

  List<ChiTieu> get _hienThi =>
      _trongThang.where((e) => _loc == null || e.danhMuc == _loc).toList();

  double get _tongThang => _trongThang.fold(0, (s, e) => s + e.soTien);

  double get _tongThangTruoc {
    final p = DateTime(_thang.year, _thang.month - 1);
    return _tatCa
        .where((e) => e.ngay.year == p.year && e.ngay.month == p.month)
        .fold(0.0, (s, e) => s + e.soTien);
  }

  int get _soNgay {
    final hn = DateTime.now();
    if (_thang.year == hn.year && _thang.month == hn.month) return hn.day;
    return DateTime(_thang.year, _thang.month + 1, 0).day;
  }

  double get _trungBinhNgay => _tongThang / _soNgay;

  double get _lonNhat => _trongThang.isEmpty
      ? 0
      : _trongThang.map((e) => e.soTien).reduce((a, b) => a > b ? a : b);

  Map<String, double> get _theoDanhMuc {
    final m = <String, double>{};
    for (final e in _trongThang) {
      m[e.danhMuc] = (m[e.danhMuc] ?? 0) + e.soTien;
    }
    final sorted = m.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {for (final e in sorted) e.key: e.value};
  }

  void _doiThang(int delta) {
    setState(() {
      _thang = DateTime(_thang.year, _thang.month + delta);
      _loc = null;
    });
  }

  Future<void> _moForm({ChiTieu? cu}) async {
    await moFormChiTieu(context, cu: cu);
    _tai();
  }

  Future<void> _xoa(ChiTieu e) async {
    setState(() => _tatCa.removeWhere((x) => x.id == e.id));
    await CoSoDuLieu.xoa(e.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Đã xóa "${e.tieuDe}"'),
          action: SnackBarAction(
            label: 'Hoàn tác',
            onPressed: () async {
              await CoSoDuLieu.them(e);
              _tai();
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final nhom = _nhomTheoNgay(_hienThi);

    return Scaffold(
      backgroundColor: MauSac.nen,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: MauSac.xanhNhat,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () => _moForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Thêm khoản chi',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: _dangTai
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: 110),
              children: [
                _dauTrang(),
                Transform.translate(
                  offset: const Offset(0, -26),
                  child: TheBieuDo(data: _theoDanhMuc, tong: _tongThang),
                ),
                _thanhLoc(),
                const SizedBox(height: 6),
                if (nhom.isEmpty) _trong(),
                for (final entry in nhom.entries) ...[
                  _tieuDeNgay(entry.key, entry.value),
                  for (final e in entry.value)
                    DongChiTieu(
                      chiTieu: e,
                      onSua: () => _moForm(cu: e),
                      onXoa: () => _xoa(e),
                    ),
                ],
              ],
            ),
    );
  }

  // ---------- Đầu trang ----------
  Widget _vong(double d, double alpha) => Container(
    width: d,
    height: d,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: alpha),
    ),
  );

  Widget _dauTrang() {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MauSac.xanhDam, Color(0xFF0E6B63), MauSac.xanhNhat],
          stops: [0, 0.6, 1],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Stack(
        children: [
          Positioned(right: -40, top: -30, child: _vong(170, 0.07)),
          Positioned(left: -60, bottom: -70, child: _vong(160, 0.05)),
          Padding(
            padding: EdgeInsets.fromLTRB(20, top + 14, 20, 54),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Sổ chi tiêu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _chonThang(),
                  ],
                ),
                const SizedBox(height: 22),
                const Text(
                  'Đã chi trong tháng',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  dinhDangVnd(_tongThang),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                _soVoiThangTruoc(),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _oThongKe(
                        Icons.today_rounded,
                        'Trung bình mỗi ngày',
                        dinhDangVnd(_trungBinhNgay),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _oThongKe(
                        Icons.trending_up_rounded,
                        'Khoản lớn nhất',
                        dinhDangVnd(_lonNhat),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chonThang() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => _doiThang(-1),
            icon: const Icon(Icons.chevron_left_rounded),
            color: Colors.white,
          ),
          Text(
            'Tháng ${_thang.month}/${_thang.year}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => _doiThang(1),
            icon: const Icon(Icons.chevron_right_rounded),
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _soVoiThangTruoc() {
    final truoc = _tongThangTruoc;
    final soKhoan = Text(
      '${_trongThang.length} khoản chi',
      style: const TextStyle(color: Colors.white70, fontSize: 13),
    );
    if (truoc == 0) return soKhoan;

    final pt = (_tongThang - truoc) / truoc * 100;
    final tang = pt >= 0;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                tang
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 14,
                color: tang ? MauSac.tang : MauSac.giam,
              ),
              const SizedBox(width: 4),
              Text(
                '${pt.abs().round()}% so với tháng trước',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        soKhoan,
      ],
    );
  }

  Widget _oThongKe(IconData icon, String nhan, String giaTri) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nhan,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  giaTri,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _thanhLoc() {
    Widget chip(String nhan, String? gia, {IconData? icon, Color? mau}) {
      final chon = _loc == gia;
      final m = mau ?? MauSac.xanhNhat;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          avatar: icon == null
              ? null
              : Icon(icon, size: 16, color: chon ? Colors.white : m),
          label: Text(nhan),
          selected: chon,
          showCheckmark: false,
          selectedColor: m,
          backgroundColor: Colors.white,
          side: BorderSide(color: chon ? m : MauSac.vien),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: chon ? Colors.white : MauSac.chu,
          ),
          onSelected: (_) => setState(() => _loc = gia),
        ),
      );
    }

    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          chip('Tất cả', null),
          for (final d in danhSachDanhMuc)
            chip(d.ten, d.ten, icon: d.icon, mau: d.mau),
        ],
      ),
    );
  }

  // ---------- Danh sách theo ngày ----------
  Map<DateTime, List<ChiTieu>> _nhomTheoNgay(List<ChiTieu> ds) {
    final m = <DateTime, List<ChiTieu>>{};
    for (final e in ds) {
      final k = DateTime(e.ngay.year, e.ngay.month, e.ngay.day);
      m.putIfAbsent(k, () => []).add(e);
    }
    final keys = m.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final k in keys) k: m[k]!};
  }

  String _nhanNgay(DateTime d) {
    final hn = DateTime.now();
    final homNay = DateTime(hn.year, hn.month, hn.day);
    final diff = homNay.difference(d).inDays;
    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Hôm qua';
    const thu = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
    return '${thu[d.weekday - 1]}, ${DateFormat('dd/MM').format(d)}';
  }

  Widget _tieuDeNgay(DateTime ngay, List<ChiTieu> ds) {
    final tong = ds.fold<double>(0, (s, e) => s + e.soTien);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _nhanNgay(ngay),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: MauSac.chu,
            ),
          ),
          Text(
            dinhDangVnd(tong),
            style: const TextStyle(fontSize: 13, color: MauSac.phu),
          ),
        ],
      ),
    );
  }

  Widget _trong() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 32),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: MauSac.xanhNhat.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 40,
              color: MauSac.xanhNhat,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có khoản chi nào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: MauSac.chu,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Bấm "Thêm khoản chi" để ghi lại khoản đầu tiên',
            textAlign: TextAlign.center,
            style: TextStyle(color: MauSac.phu),
          ),
        ],
      ),
    );
  }
}
