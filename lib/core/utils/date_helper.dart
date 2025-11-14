import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DateHelper {
  /// Pastikan init ini dipanggil sekali di awal (misal di main.dart)
  static Future<void> init() async {
    await initializeDateFormatting('id_ID', null);
  }

  /// Format tanggal ke gaya Indonesia, misal "15 Oktober 2025"
  static String formatDate(String? isoDate) {
    if (isoDate == null) return '-';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('d MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return '-';
    }
  }

  /// Format singkat, misal "15 Okt 2025"
  static String formatShort(String? isoDate) {
    if (isoDate == null) return '-';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('d MMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return '-';
    }
  }

  /// Tambahan contoh: ubah tanggal jadi format "Senin, 15 Oktober 2025"
  static String formatWithDay(String? isoDate) {
    if (isoDate == null) return '-';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return '-';
    }
  }
}
