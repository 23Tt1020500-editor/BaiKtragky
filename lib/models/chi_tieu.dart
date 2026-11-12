class ChiTieu {
  final int? id;
  final String tieuDe;
  final double soTien;
  final String danhMuc;
  final DateTime ngay;

  ChiTieu({
    this.id,
    required this.tieuDe,
    required this.soTien,
    required this.danhMuc,
    required this.ngay,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'tieuDe': tieuDe,
    'soTien': soTien,
    'danhMuc': danhMuc,
    'ngay': ngay.toIso8601String(),
  };

  factory ChiTieu.fromMap(Map<String, dynamic> m) => ChiTieu(
    id: m['id'] as int?,
    tieuDe: m['tieuDe'] as String,
    soTien: (m['soTien'] as num).toDouble(),
    danhMuc: m['danhMuc'] as String,
    ngay: DateTime.parse(m['ngay'] as String),
  );
}
