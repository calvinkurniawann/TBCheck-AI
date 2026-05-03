class ScreeningData {
  // Step 1: Data Diri
  int? umur;
  String? jenisKelamin; // 'Laki-laki' / 'Perempuan'

  // Step 2: Gejala
  String? durasiBatuk; // 'Tidak ada' / '< 2 minggu' / '> 2 minggu'
  String? frekuensiDemam; // 'Tidak pernah' / 'Kadang-kadang' / 'Sering'
  String? keringatMalam; // 'Tidak' / 'Kadang' / 'Sering'
  String? penurunanBeratBadan; // 'Tidak' / 'Sedikit' / 'Signifikan'

  // Step 3: Faktor Risiko
  bool? kontakPasienTBC;
  String? lingkunganTempatTinggal; // 'Tidak padat' / 'Cukup padat' / 'Padat & Kumuh'
  bool? merokok;

  // Step 4: Keluhan Tambahan
  String? keluhanTambahan;

  ScreeningData();

  Map<String, dynamic> toMap() {
    return {
      'umur': umur,
      'jenisKelamin': jenisKelamin,
      'durasiBatuk': durasiBatuk,
      'frekuensiDemam': frekuensiDemam,
      'keringatMalam': keringatMalam,
      'penurunanBeratBadan': penurunanBeratBadan,
      'kontakPasienTBC': kontakPasienTBC,
      'lingkunganTempatTinggal': lingkunganTempatTinggal,
      'merokok': merokok,
      'keluhanTambahan': keluhanTambahan,
    };
  }
}
