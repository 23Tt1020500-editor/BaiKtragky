import 'package:intl/intl.dart';

final _tien = NumberFormat.decimalPattern('vi_VN');

String dinhDangVnd(double v) => '${_tien.format(v.round())} ₫';
