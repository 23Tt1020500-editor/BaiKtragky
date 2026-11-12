import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../database/co_so_du_lieu.dart';
import '../models/chi_tieu.dart';
import '../models/danh_muc.dart';
import '../utils/dinh_dang.dart';
import '../utils/mau_sac.dart';

String _nhanNgay(DateTime d) {
  final hn = DateTime.now();
  final homNay = DateTime(hn.year, hn.month, hn.day);
  final ngay = DateTime(d.year, d.month, d.day);
  final diff = homNay.difference(ngay).inDays;
  if (diff == 0) return 'Hôm nay';
  if (diff == 1) return 'Hôm qua';
  return DateFormat('dd/MM/yyyy').format(d);
}

/// Mở bảng thêm / sửa khoản chi. Truyền [cu] để sửa, bỏ trống để thêm mới.
/// Trả về khi bảng đóng; nhớ tải lại danh sách sau khi gọi.
Future<void> moFormChiTieu(BuildContext context, {ChiTieu? cu}) async {
  final tieuDeCtrl = TextEditingController(text: cu?.tieuDe ?? '');
  final tienCtrl = TextEditingController(
    text: cu == null ? '' : cu.soTien.round().toString(),
  );
  String danhMuc = cu?.danhMuc ?? danhSachDanhMuc.first.ten;
  DateTime ngay = cu?.ngay ?? DateTime.now();
  String? loi;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) {
        final dangNhap = double.tryParse(tienCtrl.text) ?? 0;
        final mauChon = layDanhMuc(danhMuc).mau;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: MauSac.vien,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  cu == null ? 'Thêm khoản chi' : 'Sửa khoản chi',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: MauSac.chu,
                  ),
                ),
                const SizedBox(height: 14),

                // ---- Số tiền ----
                TextField(
                  controller: tienCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setS(() => loi = null),
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: mauChon,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: const TextStyle(color: MauSac.vien),
                    suffixText: '₫',
                    border: InputBorder.none,
                    errorText: loi,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Text(
                  dinhDangVnd(dangNhap),
                  style: const TextStyle(fontSize: 13, color: MauSac.phu),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [10000, 20000, 50000, 100000].map((n) {
                    return ActionChip(
                      label: Text('+${n ~/ 1000}k'),
                      backgroundColor: MauSac.nen,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onPressed: () {
                        tienCtrl.text = (dangNhap + n).round().toString();
                        setS(() => loi = null);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // ---- Nội dung ----
                TextField(
                  controller: tieuDeCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Chi cho việc gì?',
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                    filled: true,
                    fillColor: MauSac.nen,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ---- Danh mục ----
                const Text(
                  'Danh mục',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: MauSac.phu,
                  ),
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, box) {
                    final w = (box.maxWidth - 16) / 3;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: danhSachDanhMuc.map((d) {
                        final chon = d.ten == danhMuc;
                        return GestureDetector(
                          onTap: () => setS(() => danhMuc = d.ten),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: w,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: chon
                                  ? d.mau.withValues(alpha: 0.14)
                                  : MauSac.nen,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: chon ? d.mau : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(d.icon, color: d.mau),
                                const SizedBox(height: 4),
                                Text(
                                  d.ten,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: chon
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: MauSac.chu,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // ---- Ngày ----
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final p = await showDatePicker(
                      context: ctx,
                      initialDate: ngay,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (p != null) setS(() => ngay = p);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: MauSac.nen,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 20,
                          color: MauSac.phu,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _nhanNgay(ngay),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: MauSac.phu,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ---- Nút lưu ----
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: MauSac.xanhNhat,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () async {
                      final soTien = double.tryParse(tienCtrl.text);
                      if (soTien == null || soTien <= 0) {
                        setS(() => loi = 'Nhập số tiền lớn hơn 0');
                        return;
                      }
                      final tieuDe = tieuDeCtrl.text.trim().isEmpty
                          ? danhMuc
                          : tieuDeCtrl.text.trim();
                      final moi = ChiTieu(
                        id: cu?.id,
                        tieuDe: tieuDe,
                        soTien: soTien,
                        danhMuc: danhMuc,
                        ngay: ngay,
                      );
                      if (cu == null) {
                        await CoSoDuLieu.them(moi);
                      } else {
                        await CoSoDuLieu.sua(moi);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text(
                      cu == null ? 'Lưu khoản chi' : 'Cập nhật',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
