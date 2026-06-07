```markdown
# TBCheck AI

TBCheck AI adalah aplikasi mobile berbasis Flutter yang dirancang untuk melakukan skrining awal risiko Tuberkulosis (TBC). Aplikasi ini mengumpulkan data indikasi medis pengguna melalui alur formulir bertahap, lalu memprosesnya menggunakan Supabase RPC untuk menghasilkan diagnosis tingkat risiko serta menyimpan riwayat pemeriksaan secara terpusat.

## Fitur Utama

* **Autentikasi Pengguna:** Sistem *Log In* dan *Register* terintegrasi dengan Supabase Auth.
* **Alur Skrining Bertahap (Multi-step Form):** Kuesioner interaktif yang dibagi menjadi 4 tahapan untuk menjaga kenyamanan *user experience*.
* **Kalkulator BMI Otomatis:** Menghitung Indeks Massa Tubuh secara *real-time* pada langkah pengisian data diri pasien.
* **Screening Result Berbasis Supabase RPC:** Perhitungan persentase dan tingkat risiko TBC diproses secara aman di sisi *backend* menggunakan Remote Procedure Call (RPC).
* **Penyimpanan Riwayat Terpusat:** Hasil pemeriksaan disimpan otomatis ke dalam akun pengguna yang telah terautentikasi.
* **Antarmuka Modern (Material 3):** Desain visual bersih menggunakan komponen Material Design 3 dan skema warna global kustom.

---

## Deskripsi Antarmuka (UI) & Alur Transisi

Bagian ini menjelaskan visualisasi komponen antarmuka yang dibuat dan bagaimana logika navigasi bekerja memindahkan pengguna antar-halaman.

### 1. Deskripsi Komponen UI (Custom Widgets)
Untuk menjaga konsistensi desain Material 3, aplikasi ini mengimplementasikan beberapa widget kustom:
* **`ProgressHeader`:** Komponen visual di bagian atas halaman skrining yang menunjukkan posisi langkah pengguna saat ini (contoh: "Langkah 1 dari 4").
* **`QuestionCard`:** Wadah (*container*) berbasis kartu untuk membungkus teks pertanyaan agar fokus pengguna tidak terpecah.
* **`RadioOptionTile` & `CheckboxOptionTile`:** Tombol pilihan tunggal dan jamak yang didesain secara kustom dengan *feedback* visual yang responsif saat ditekan.
* **`PrimaryButton`:** Tombol aksi utama aplikasi yang warnanya terikat dengan tema global (`app_colors.dart`).

### 2. Alur Navigasi & Transisi Halaman
Perpindahan halaman diatur secara modular melalui rute (*named routes*) dengan logika transisi sebagai berikut:

* **`SplashScreen` $\rightarrow$ `LoginScreen` / `MainNavScreen`**
    Saat aplikasi dibuka, sistem memeriksa *session* pengguna via `shared_preferences`. Jika belum login, halaman akan berpindah ke `/login`. Jika sudah login, aplikasi menggunakan transisi *fade-in* langsung menuju halaman utama (`/home`).
* **`MainNavScreen` (Bottom Navigation)**
    Berfungsi sebagai induk navigasi untuk 4 halaman utama (`HomeScreen`, `HistoryScreen`, `ClinicScreen`, `ProfileScreen`). Perpindahan antar-halaman ini bersifat instan tanpa memuat ulang (*re-load*) seluruh struktur aplikasi untuk menjaga performa.
* **`HomeScreen` $\rightarrow$ `ScreeningFlowScreen` (`/screening`)**
    Ketika pengguna menekan tombol *Call to Action* (CTA) "Mulai Skrining", aplikasi memicu transisi *slide* horizontal (bergeser dari kanan ke kiri) menuju halaman formulir.
* **Perpindahan Step Skrining (Step 1 s/d Step 4)**
    Formulir bertahap dibungkus menggunakan komponen `PageView`. Perpindahan dari Data Diri $\rightarrow$ Gejala $\rightarrow$ Faktor Risiko $\rightarrow$ Keluhan Tambahan dilakukan dengan gestur geser yang halus (*smooth sliding transition*).
* **Submit $\rightarrow$ `ScreeningResultScreen`**
    Setelah menekan tombol 'Kirim' di langkah terakhir, data dikirim ke Supabase. Setelah respons sukses diterima, aplikasi mengarahkan pengguna ke halaman hasil dengan transisi memudar (*fade transition*), menampilkan tingkat risiko terduga TBC.

---

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

---

## Alur Aplikasi & Navigasi Halaman

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

---

## Alur Data Aplikasi

1. **Inisialisasi Form:** Pengguna membuka halaman `/screening`, `ScreeningFlowScreen` otomatis menginstansiasi satu objek `ScreeningData`.
2. **Mutasi Data:** Setiap *sub-screen* (`step1` sampai `step4`) menerima referensi objek `ScreeningData` yang sama melalui konstruktor. Setiap kali pengguna memilih jawaban, data langsung dimutasi ke dalam objek tersebut.
3. **Proses Backend:** Pada langkah terakhir, objek data dikirim ke fungsi RPC Supabase `calculate_screening`.
4. **Sinkronisasi Riwayat:** Jika pengguna dalam kondisi *logged in*, hasil perhitungan screening akan otomatis disimpan ke tabel database `screening_histories`.
5. **Output UI:** Hasil akhir yang dikembalikan oleh database disajikan secara visual di `ScreeningResultScreen`.

---

## Konfigurasi Supabase

Seluruh kredensial dan endpoint Supabase dikelola secara terpusat pada file:
`lib/core/constants/supabase_config.dart`

Komponen kunci yang digunakan:

* `supabaseUrl` & `supabaseAnonKey`: Menangani jembatan koneksi API dan autentikasi.
* `screeningRpc` (`calculate_screening`): Fungsi PostgreSQL di database untuk kalkulasi skor risiko TBC.
* `historyTable` (`screening_histories`): Tabel penyimpanan riwayat pengguna.
* `storageBucket` (`uploads`): Penyimpanan berkas atau dokumen pendukung.

> **Peringatan:** Jika bermigrasi ke *environment* baru, pastikan nilai variabel di dalam file `supabase_config.dart` ini telah diperbarui sesuai dengan proyek Supabase yang aktif.

---

## Panduan Menjalankan Proyek

1. Pastikan dependensi proyek terpasang dengan benar:
```bash
flutter pub get

```


2. Jalankan aplikasi pada emulator atau perangkat fisik yang terhubung:
```bash
flutter run

```


3. Pastikan perangkat memiliki koneksi internet aktif agar sinkronisasi data dengan Supabase berjalan lancar.

---

## Catatan Pengembangan

* **Orientasi Layar:** Aplikasi dikunci secara programatis pada mode *Portrait* (`DeviceOrientation.portraitUp`).
* **Manajemen Tema:** Tema global (Dark/Light mode) diatur langsung pada *entry point* aplikasi di `lib/main.dart`.
* **Akses Data Lokal:** Beberapa data fiktif (*mock data*) digunakan pada halaman Klinik dan Riwayat untuk keperluan akselerasi pengembangan antarmuka (UI development).

---

## Entry Point

* [`lib/main.dart`](https://www.google.com/search?q=lib/main.dart)

File ini menangani inisialisasi Supabase, pengaturan orientasi layar, theme aplikasi, dan registrasi route utama:

* `/` (Splash Screen / Root)
* `/login`
* `/register`
* `/home`
* `/screening`

```

```