class ScreeningData {
  int? usia;
  String? jenisKelamin;
  double? tinggiBadan;
  double? beratBadan;

  bool? batukLama;
  bool? batukDarah;

  List<String> gejalaSistemik = [];

  List<String> faktorLingkungan = [];

  List<String> gayaHidupKomorbid = [];

  ScreeningData();

  double? get bmi {
    if (tinggiBadan != null && beratBadan != null && tinggiBadan! > 0) {
      final heightM = tinggiBadan! / 100;
      return beratBadan! / (heightM * heightM);
    }
    return null;
  }

  String get bmiCategory {
    final val = bmi;
    if (val == null) return '-';
    if (val < 18.5) return 'Kurus';
    if (val < 25.0) return 'Normal';
    if (val < 30.0) return 'Gemuk';
    return 'Obesitas';
  }

  Map<String, dynamic> toMap() {
    return {
      'usia': usia,
      'jenisKelamin': jenisKelamin,
      'tinggiBadan': tinggiBadan,
      'beratBadan': beratBadan,
      'bmi': bmi,
      'bmiCategory': bmiCategory,
      'batukLama': batukLama,
      'batukDarah': batukDarah,
      'gejalaSistemik': gejalaSistemik,
      'faktorLingkungan': faktorLingkungan,
      'gayaHidupKomorbid': gayaHidupKomorbid,
    };
  }
}
