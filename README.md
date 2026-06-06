# TBCheck AI

TBCheck AI adalah aplikasi mobile berbasis Flutter untuk skrining awal risiko tuberkulosis (TBC). Aplikasi ini mengumpulkan data pengguna melalui alur formulir bertahap, lalu mengirimkannya ke Supabase untuk dihitung menjadi hasil screening dan riwayat pemeriksaan.

## Fitur Utama

- Autentikasi pengguna: login dan register
- Alur skrining bertahap 4 langkah
- Perhitungan BMI otomatis pada data diri
- Screening result berbasis Supabase RPC
- Penyimpanan riwayat screening per pengguna
- Halaman beranda, riwayat, klinik, profil, dan notifikasi
- Desain UI Material 3 dengan tema global kustom

## Teknologi

- Flutter
- Dart
- Supabase
- Material Design 3
- `shared_preferences`
- `flutter_map`
- `geolocator`
- `url_launcher`

## Struktur Proyek

```text
lib/
|-- core/
|   |-- constants/
|   |   |-- app_colors.dart
|   |   |-- app_text_styles.dart
|   |   `-- supabase_config.dart
|   `-- services/
|       `-- screening_api_service.dart
|-- models/
|   |-- clinic_data.dart
|   |-- screening_data.dart
|   `-- screening_history.dart
|-- screens/
|   |-- auth/
|   |   |-- login_screen.dart
|   |   `-- register_screen.dart
|   |-- clinic/
|   |   `-- clinic_screen.dart
|   |-- home/
|   |   `-- home_screen.dart
|   |-- history/
|   |   |-- history_detail_screen.dart
|   |   `-- history_screen.dart
|   |-- main/
|   |   `-- main_nav_screen.dart
|   |-- notifications/
|   |   `-- notifications_screen.dart
|   |-- profile/
|   |   `-- profile_screen.dart
|   |-- result/
|   |   `-- screening_result_screen.dart
|   |-- screening/
|   |   |-- screening_flow_screen.dart
|   |   |-- step1_data_diri.dart
|   |   |-- step2_gejala.dart
|   |   |-- step3_faktor_risiko.dart
|   |   `-- step4_keluhan_tambahan.dart
|   `-- splash/
|       `-- splash_screen.dart
|-- widgets/
|   |-- bottom_nav_bar.dart
|   |-- checkbox_option_tile.dart
|   |-- chip_selector.dart
|   |-- multi_select_chip.dart
|   |-- primary_button.dart
|   |-- progress_header.dart
|   |-- question_card.dart
|   `-- radio_option_tile.dart
`-- main.dart
```

## Alur Aplikasi

```text
Splash Screen -> Main Nav Screen
                 |-- Beranda
                 |   |-- CTA -> /screening
                 |   `-- Lihat riwayat
                 |-- Skrining -> /screening
                 |   `-- Step 1 -> Step 2 -> Step 3 -> Step 4 -> Submit
                 |-- Klinik
                 `-- Profil
```

## Alur Data

1. Pengguna membuka halaman `/screening`.
2. `ScreeningFlowScreen` membuat satu objek `ScreeningData`.
3. Setiap halaman step menerima objek yang sama melalui konstruktor.
4. Saat pengguna memilih jawaban, data langsung dimutasi ke objek tersebut.
5. Setelah langkah terakhir, data dikirim ke Supabase RPC `calculate_screening`.
6. Hasil screening disimpan ke tabel `screening_histories` jika pengguna sedang login.
7. Hasil akhir ditampilkan di layar hasil screening.

## Konfigurasi Supabase

Konfigurasi Supabase berada di:

- [`lib/core/constants/supabase_config.dart`](lib/core/constants/supabase_config.dart)

Bagian yang dipakai aplikasi:

- `supabaseUrl`
- `supabaseAnonKey`
- `screeningRpc` = `calculate_screening`
- `historyTable` = `screening_histories`
- `storageBucket` = `uploads`

Jika ingin menjalankan proyek ini di environment baru, pastikan nilai Supabase di file tersebut sudah sesuai dengan project Supabase milikmu.

## Menjalankan Proyek

1. Install dependency:

```bash
flutter pub get
```

2. Jalankan aplikasi:

```bash
flutter run
```

3. Jika memakai emulator atau device fisik, pastikan koneksi ke Supabase aktif dan aturan autentikasi/database sudah disiapkan.

## Catatan Pengembangan

- Aplikasi menggunakan orientasi portrait.
- Tema global diatur di `lib/main.dart`.
- Riwayat screening hanya tersimpan jika user sudah login.
- Beberapa data klinik dan riwayat menggunakan mock data untuk kebutuhan UI development.

## Entry Point

- [`lib/main.dart`](lib/main.dart)

File ini menangani inisialisasi Supabase, pengaturan orientasi layar, theme aplikasi, dan route utama:

- `/`
- `/login`
- `/register`
- `/home`
- `/screening`
