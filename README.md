# TBCheck AI - Dokumentasi Proyek

## 1. Tentang Proyek Ini
**TBCheck AI** adalah sebuah aplikasi mobile berbasis Flutter yang dirancang untuk melakukan *screening* (penapisan) awal terhadap risiko penyakit Tuberkulosis (TBC). Aplikasi ini memandu pengguna melalui serangkaian kuesioner terstruktur (seperti data diri, gejala yang dialami, dan faktor risiko lingkungan/kebiasaan) menggunakan antarmuka formulir bertahap (*wizard*). Tujuan akhir dari aplikasi ini adalah mengumpulkan data kesehatan pengguna untuk kemudian dianalisis (oleh sistem AI di tahap selanjutnya) guna memberikan indikasi tingkat risiko TBC.

## 2. Teknologi yang Digunakan
- **Framework Utama:** Flutter (Dart)
- **Desain & UI:** Material Design 3 (Material 3), kustomisasi tema global via `ThemeData`.
- **Manajemen State (Lokal):** `StatefulWidget` biasa untuk mengelola state lokal dan pergerakan antar halaman kuesioner.

## 3. Struktur Proyek
Secara umum, *source code* utama berada di dalam folder `lib/`, dengan pembagian struktur yang modular:

```text
lib/
├── core/
│   └── constants/         # Menyimpan nilai-nilai konstan (Warna, Tipografi)
├── models/                # Mendefinisikan struktur data / entitas
├── screens/               # Halaman-halaman utama (UI/Views)
│   ├── screening/         # Alur halaman kuesioner screening
│   └── splash/            # Halaman awal saat aplikasi dibuka
├── widgets/               # Komponen UI yang dapat digunakan kembali (Reusable Components)
└── main.dart              # Titik masuk utama (Entry Point) aplikasi
```

## 4. Penjelasan Folder dan Fungsi Setiap File

### `lib/main.dart`
Berfungsi sebagai titik masuk utama (*entry point*). File ini melakukan inisialisasi aplikasi (`runApp`), mengonfigurasi tema global (seperti `fontFamily: 'Poppins'`, warna primer, gaya AppBar), serta mengatur *routing* dasar (navigasi antara layar Splash dan layar Screening).

### `lib/core/constants/`
- **`app_colors.dart`**: Berisi definisi palet warna global yang digunakan di seluruh aplikasi (misalnya warna biru utama, warna latar belakang, warna peringatan risiko).
- **`app_text_styles.dart`**: (Diasumsikan) Berisi definisi gaya tulisan (*text styles*) untuk memastikan konsistensi tipografi di seluruh UI.

### `lib/models/`
- **`screening_data.dart`**: Mendefinisikan kelas `ScreeningData`. Ini adalah model data yang menampung seluruh jawaban pengguna dari tahap 1 hingga tahap 4. File ini juga memiliki metode `toMap()` untuk mempermudah konversi data sebelum dikirim ke API/Backend.

### `lib/screens/splash/`
- **`splash_screen.dart`**: Halaman pembuka aplikasi (Splash Screen) yang biasanya menampilkan logo atau animasi singkat sebelum mengarahkan pengguna ke halaman utama / *screening*.

### `lib/screens/screening/`
- **`screening_flow_screen.dart`**: Ini adalah halaman *Controller* utama untuk proses kuesioner. File ini mengatur `PageView` dan `PageController` untuk menggeser antar langkah (Step 1 hingga Step 4). File ini juga menyimpan *instance* dari `ScreeningData` dan fungsi untuk berpindah ke langkah selanjutnya atau sebelumnya, serta menampilkan dialog sukses saat data di-submit.
- **`step1_data_diri.dart`**: Halaman langkah pertama untuk mengambil data demografi (umur, jenis kelamin).
- **`step2_gejala.dart`**: Halaman langkah kedua yang menanyakan gejala fisik (durasi batuk, demam, keringat malam, penurunan berat badan).
- **`step3_faktor_risiko.dart`**: Halaman langkah ketiga tentang risiko lingkungan (kontak dengan pasien, kepadatan tempat tinggal, kebiasaan merokok).
- **`step4_keluhan_tambahan.dart`**: Halaman terakhir berupa *text area* untuk mengisi keluhan spesifik lainnya secara bebas.

### `lib/widgets/`
Berisi komponen-komponen UI kecil yang dipisah agar rapi dan bisa dipakai berulang:
- **`bottom_nav_bar.dart`**: Navigasi bawah aplikasi.
- **`progress_header.dart`**: AppBar khusus yang menampilkan indikator progres pengisian kuesioner (Langkah X dari 4).
- **`radio_option_tile.dart` & `checkbox_option_tile.dart`**: Komponen kustom untuk memilih opsi (satu pilihan atau lebih).
- **`chip_selector.dart`**: Opsi pilihan bergaya tombol *chip*.
- **`primary_button.dart`**: Tombol utama standar aplikasi.
- **`question_card.dart`**: Desain kotak/kartu untuk membungkus setiap pertanyaan kuesioner.

## 5. Aliran Data (Data Flow)

Aliran data dalam aplikasi ini difokuskan pada pengumpulan data *screening* pengguna, dengan alur sebagai berikut:

1. **Inisialisasi Data:** Saat pengguna masuk ke rute `/screening`, `ScreeningFlowScreen` akan dipanggil. Di dalamnya, sebuah objek tunggal `_screeningData` (dari kelas `ScreeningData`) dibuat secara kosong.
2. **Distribusi Data:** Objek `_screeningData` tersebut diteruskan (di-*passing*) ke setiap halaman *step* (`Step1DataDiri`, `Step2Gejala`, dst.) melalui parameter konstruktor.
3. **Mutasi Data:** 
   - Setiap kali pengguna memilih opsi di salah satu halaman *step* (misalnya memilih jenis kelamin di Step 1), state lokal di halaman tersebut diperbarui agar UI merefleksikan pilihan tersebut.
   - Secara bersamaan, nilai tersebut langsung diisikan (*mutate*) ke dalam objek `_screeningData` yang diteruskan tadi (contoh: `widget.data.jenisKelamin = 'Laki-laki';`).
4. **Navigasi:** Ketika pengguna menekan tombol "Selanjutnya", `ScreeningFlowScreen` akan memanggil `PageController.animateToPage()` untuk berpindah layar, namun objek datanya tetap satu yang sama dan terus terakumulasi isinya.
5. **Submit / Output:** Pada langkah terakhir (Step 4), ketika pengguna menekan "Kirim" atau "Selesai", objek `_screeningData` kini telah berisi data lengkap dari Step 1 hingga Step 4.
6. **Akhir Aliran (Saat ini):** Fungsi `_onSubmit()` di `ScreeningFlowScreen` dipanggil. Pada tahap ini, seluruh entitas dapat diubah menjadi Map/JSON menggunakan `_screeningData.toMap()` dan siap untuk dikirim ke *Backend* atau layanan AI. Saat ini, alur berakhir dengan menampilkan *Dialog* sukses (pop-up) kepada pengguna.
