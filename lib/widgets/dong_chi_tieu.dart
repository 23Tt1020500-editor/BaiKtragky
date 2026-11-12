import 'package:flutter/material.dart';

import '../models/chi_tieu.dart';
import '../models/danh_muc.dart';
import '../utils/dinh_dang.dart';
import '../utils/mau_sac.dart';

/// Một dòng khoản chi: bấm để sửa, vuốt sang trái để xóa.
class DongChiTieu extends StatelessWidget {
  final ChiTieu chiTieu;
  final VoidCallback onSua;
  final VoidCallback onXoa;

  const DongChiTieu({
    super.key,
    required this.chiTieu,
    required this.onSua,
    required this.onXoa,
  });

  @override
  Widget build(BuildContext context) {
    final e = chiTieu;
    final dm = layDanhMuc(e.danhMuc);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Dismissible(
          key: ValueKey('chi_tieu_${e.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            color: MauSac.chi,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: const Icon(Icons.delete_rounded, color: Colors.white),
          ),
          onDismissed: (_) => onXoa(),
          child: Material(
            color: Colors.white,
            child: InkWell(
              onTap: onSua,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: dm.mau.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(dm.icon, color: dm.mau, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.tieuDe,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: MauSac.chu,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            e.danhMuc,
                            style: const TextStyle(
                              fontSize: 12,
                              color: MauSac.phu,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '-${dinhDangVnd(e.soTien)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: MauSac.chi,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
