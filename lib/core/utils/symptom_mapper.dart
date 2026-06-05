import '../../models/screening_data.dart';

/// Maps the Flutter screening form data to the screening engine's symptom codes.
///
/// Backend uses codes like:
/// - G01-G08: Gejala (symptoms)
/// - R01-R05: Risiko lingkungan (environmental risks)
/// - K01-K04: Komorbid / gaya hidup (lifestyle/comorbid)
class SymptomMapper {
  /// Convert [ScreeningData] from the 4-step form into a flat list of
  /// symptom codes that the Supabase screening RPC expects.
  static List<String> mapToBackendCodes(ScreeningData data) {
    final codes = <String>[];

    // ── Step 2: Gejala Utama ──
    // G01 = Batuk lama (≥ 3 minggu)
    if (data.batukLama == true) codes.add('G01');
    // G02 = Batuk darah (Hemoptisis)
    if (data.batukDarah == true) codes.add('G02');

    // ── Step 3: Gejala Sistemik ──
    const gejalaSistemikMap = {
      'demam_lama': 'G03',        // Demam lama / meriang
      'penurunan_bb': 'G04',      // Penurunan berat badan drastis
      'nafsu_makan_turun': 'G05', // Penurunan nafsu makan
      'malaise': 'G06',           // Lemah / lemas (malaise)
      'sesak_napas': 'G07',       // Sesak napas / nyeri dada
      'keringat_malam': 'G08',    // Keringat malam
    };

    for (final item in data.gejalaSistemik) {
      final code = gejalaSistemikMap[item];
      if (code != null) codes.add(code);
    }

    // ── Step 4: Faktor Lingkungan & Riwayat Kontak ──
    const lingkunganMap = {
      'serumah_tbc': 'R01',       // Tinggal serumah dengan penderita TBC
      'kontak_luar': 'R02',       // Kontak intensif di luar rumah
      'ventilasi_buruk': 'R03',   // Rumah tanpa ventilasi
      'pemukiman_padat': 'R04',   // Pemukiman padat / kumuh
    };

    for (final item in data.faktorLingkungan) {
      final code = lingkunganMap[item];
      if (code != null) codes.add(code);
    }

    // ── Step 4: Gaya Hidup & Komorbid ──
    const gayaHidupMap = {
      'perokok': 'K01',           // Perokok / mantan perokok
      'alkohol': 'K02',           // Konsumsi alkohol
      'gizi_buruk': 'K03',       // Gizi buruk
      'riwayat_imun': 'K04',     // Riwayat penyakit penurun imun
    };

    for (final item in data.gayaHidupKomorbid) {
      final code = gayaHidupMap[item];
      if (code != null) codes.add(code);
    }

    return codes;
  }

  /// Reverse map: translate code to human-readable Indonesian label.
  static String codeToLabel(String code) {
    const labels = {
      'G01': 'Batuk ≥ 3 minggu',
      'G02': 'Batuk darah',
      'G03': 'Demam lama / meriang',
      'G04': 'Penurunan berat badan',
      'G05': 'Nafsu makan turun',
      'G06': 'Lemah / lemas',
      'G07': 'Sesak napas / nyeri dada',
      'G08': 'Keringat malam',
      'R01': 'Serumah dengan penderita TBC',
      'R02': 'Kontak luar dengan penderita TBC',
      'R03': 'Ventilasi rumah buruk',
      'R04': 'Pemukiman padat',
      'R05': 'Faktor risiko lainnya',
      'K01': 'Perokok',
      'K02': 'Konsumsi alkohol',
      'K03': 'Gizi buruk',
      'K04': 'Riwayat penyakit penurun imun',
    };
    return labels[code] ?? code;
  }
}
