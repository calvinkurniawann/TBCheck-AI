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
│   └── constants/
│       ├── app_colors.dart
│       └── app_text_styles.dart
├── models/
│   ├── screening_data.dart
│   ├── screening_history.dart
│   └── clinic_data.dart
├── screens/
│   ├── main/
│   │   └── main_nav_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── history/
│   │   └── history_screen.dart
│   ├── clinic/
│   │   └── clinic_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   ├── screening/
│   │   ├── screening_flow_screen.dart
│   │   ├── step1_data_diri.dart
│   │   ├── step2_gejala.dart
│   │   ├── step3_faktor_risiko.dart
│   │   └── step4_keluhan_tambahan.dart
│   └── splash/
│       └── splash_screen.dart
├── widgets/
│   ├── bottom_nav_bar.dart
│   ├── checkbox_option_tile.dart
│   ├── chip_selector.dart
│   ├── multi_select_chip.dart
│   ├── primary_button.dart
│   ├── progress_header.dart
│   ├── question_card.dart
│   └── radio_option_tile.dart
└── main.dart
```

## 4. Penjelasan Folder dan Fungsi Setiap File

### `lib/main.dart`
Berfungsi sebagai titik masuk utama (*entry point*). File ini melakukan inisialisasi aplikasi (`runApp`), mengonfigurasi tema global (seperti `fontFamily: 'Poppins'`, warna primer, gaya AppBar), serta mengatur *routing* dasar (navigasi antara layar Splash, Main Nav, dan Screening).

### `lib/core/constants/`
- **`app_colors.dart`**: Berisi definisi palet warna global yang digunakan di seluruh aplikasi (misalnya warna biru utama, warna latar belakang, warna peringatan risiko).
- **`app_text_styles.dart`**: Berisi definisi gaya tulisan (*text styles*) untuk memastikan konsistensi tipografi di seluruh UI.

### `lib/models/`
- **`screening_data.dart`**: Mendefinisikan kelas `ScreeningData`. Ini adalah model data yang menampung seluruh jawaban pengguna dari tahap 1 hingga tahap 4, termasuk kalkulasi BMI otomatis. File ini juga memiliki metode `toMap()` untuk mempermudah konversi data sebelum dikirim ke API/Backend.
- **`screening_history.dart`**: Model data untuk riwayat skrining dengan enum `RiskLevel`, helper warna/ikon per level risiko, format `timeAgo`, dan mock data untuk pengembangan UI.
- **`clinic_data.dart`**: Model data untuk klinik/puskesmas dengan indikator DOTS, format jarak, rating, dan mock data.

### `lib/screens/splash/`
- **`splash_screen.dart`**: Halaman pembuka aplikasi (Splash Screen) yang menampilkan logo dan animasi singkat sebelum mengarahkan pengguna ke halaman utama (Main Nav).

### `lib/screens/main/`
- **`main_nav_screen.dart`**: Scaffold utama yang mengatur BottomNavigationBar dengan 4 tab (Beranda, Skrining, Klinik, Profil). Tab Skrining menggunakan desain tombol teal elevated yang menavigasi ke alur skrining terpisah.

### `lib/screens/home/`
- **`home_screen.dart`**: Halaman beranda dengan SliverAppBar (sapaan pengguna, status terakhir), kartu CTA skrining, statistik cepat, ringkasan skrining terakhir, dan horizontal scroll tips kesehatan.

### `lib/screens/history/`
- **`history_screen.dart`**: Halaman riwayat skrining dengan ringkasan bar (jumlah per level risiko) dan daftar vertikal kartu riwayat dengan color coding.

### `lib/screens/clinic/`
- **`clinic_screen.dart`**: Halaman pencarian klinik terdekat dengan placeholder peta (setengah layar atas) dan bottom sheet daftar klinik rujukan DOTS.

### `lib/screens/profile/`
- **`profile_screen.dart`**: Halaman profil dengan avatar, data demografi dalam grid, menu pengaturan, dan tombol keluar.

### `lib/screens/screening/`
- **`screening_flow_screen.dart`**: Ini adalah halaman *Controller* utama untuk proses kuesioner. File ini mengatur `PageView` dan `PageController` untuk menggeser antar langkah (Step 1 hingga Step 4).
- **`step1_data_diri.dart`**: Halaman langkah pertama untuk mengambil data demografi (usia, jenis kelamin, tinggi badan, berat badan) dengan kalkulasi BMI live.
- **`step2_gejala.dart`**: Halaman langkah kedua mengenai gejala utama (batuk ≥ 3 minggu) dengan conditional logic untuk pertanyaan batuk darah.
- **`step3_faktor_risiko.dart`**: Halaman langkah ketiga tentang gejala sistemik menggunakan multi-select chip buttons.
- **`step4_keluhan_tambahan.dart`**: Halaman terakhir tentang faktor lingkungan dan gaya hidup/komorbid menggunakan multi-select chip buttons.

### `lib/widgets/`
Berisi komponen-komponen UI kecil yang dipisah agar rapi dan bisa dipakai berulang:
- **`bottom_nav_bar.dart`**: Navigasi bawah aplikasi (legacy, digantikan oleh nav dalam `main_nav_screen.dart`).
- **`progress_header.dart`**: AppBar khusus yang menampilkan indikator progres pengisian kuesioner (Langkah X dari 4).
- **`radio_option_tile.dart` & `checkbox_option_tile.dart`**: Komponen kustom untuk memilih opsi (satu pilihan atau lebih).
- **`chip_selector.dart`**: Opsi pilihan bergaya tombol *chip* (single-select).
- **`multi_select_chip.dart`**: Widget multi-select chip buttons dengan animasi dan check indicator.
- **`primary_button.dart`**: Tombol utama standar aplikasi.
- **`question_card.dart`**: Desain kotak/kartu untuk membungkus setiap pertanyaan kuesioner.

## 5. Aliran Data (Data Flow)

Aliran data dalam aplikasi ini difokuskan pada pengumpulan data *screening* pengguna, dengan alur sebagai berikut:

1. **Inisialisasi Data:** Saat pengguna masuk ke rute `/screening`, `ScreeningFlowScreen` akan dipanggil. Di dalamnya, sebuah objek tunggal `_screeningData` (dari kelas `ScreeningData`) dibuat secara kosong.
2. **Distribusi Data:** Objek `_screeningData` tersebut diteruskan (di-*passing*) ke setiap halaman *step* (`Step1DataDiri`, `Step2GejalaUtama`, dst.) melalui parameter konstruktor.
3. **Mutasi Data:** 
   - Setiap kali pengguna memilih opsi di salah satu halaman *step* (misalnya memilih jenis kelamin di Step 1), state lokal di halaman tersebut diperbarui agar UI merefleksikan pilihan tersebut.
   - Secara bersamaan, nilai tersebut langsung diisikan (*mutate*) ke dalam objek `_screeningData` yang diteruskan tadi (contoh: `widget.data.jenisKelamin = 'Laki-laki';`).
4. **Navigasi:** Ketika pengguna menekan tombol "Selanjutnya", `ScreeningFlowScreen` akan memanggil `PageController.animateToPage()` untuk berpindah layar, namun objek datanya tetap satu yang sama dan terus terakumulasi isinya.
5. **Submit / Output:** Pada langkah terakhir (Step 4), ketika pengguna menekan "Analisis Sekarang", objek `_screeningData` kini telah berisi data lengkap dari Step 1 hingga Step 4.
6. **Akhir Aliran (Saat ini):** Fungsi `_onSubmit()` di `ScreeningFlowScreen` dipanggil. Pada tahap ini, seluruh entitas dapat diubah menjadi Map/JSON menggunakan `_screeningData.toMap()` dan siap untuk dikirim ke *Backend* atau layanan AI. Saat ini, alur berakhir dengan menampilkan *Dialog* sukses (pop-up) kepada pengguna.

## 6. Alur Navigasi Aplikasi

```
Splash Screen → Main Nav Screen
                  ├── Tab 0: Beranda (Home)
                  │     ├── CTA → /screening
                  │     └── Lihat Semua → Riwayat
                  ├── Tab 1: Skrining → /screening (push)
                  │     └── Step 1 → Step 2 → Step 3 → Step 4 → Submit
                  ├── Tab 2: Klinik
                  └── Tab 3: Profil
```
