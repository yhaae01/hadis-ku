# HadisKu

Aplikasi Flutter untuk mencari dan membaca hadis dengan teks Arab serta
terjemahan bahasa Indonesia. Data diambil dari
[hadis-api-id](https://github.com/renomureza/hadis-api-id)
(base URL: `https://hadis-api-id.vercel.app`).

## Fitur

- **Beranda** — daftar 9 kitab hadis beserta jumlah hadisnya dan deret topik
  pilihan.
- **Daftar hadis** — pagination 20 hadis per halaman dengan *lazy loading*
  saat di-scroll dan *pull to refresh*.
- **Detail hadis** — nomor hadis, teks Arab (RTL), dan terjemahan Indonesia
  yang bisa diseleksi.
- **Pencarian** — masukkan nomor hadis untuk membuka detail secara langsung,
  atau kata kunci untuk memindai kitab terpilih. Pencarian bisa dihentikan.
- **Topik hadis** — halaman kategori (Niat, Iman, Shalat, Akhlak, Makanan &
  Minuman, Sabar, Ilmu, Sedekah) lengkap dengan hadis rujukan dan hasil
  pencarian kata kunci.
- **Mode offline (Hive)** — kitab, halaman daftar, detail hadis, dan hasil
  pencarian yang pernah dimuat disimpan otomatis di perangkat.
- **Tema** — Material 3 dengan palet hijau tua, putih kehijauan, dan aksen
  emas.
- **Splash screen & app icon** — dibuat dengan `flutter_native_splash` dan
  `flutter_launcher_icons`.

## Persyaratan

- Flutter 3.47+ (Dart 3.13+)
- Android Studio / Xcode sesuai platform target

## Langkah Setup

```bash
# 1. Ambil dependency
flutter pub get

# 2. Generate splash screen native (sekali, atau setiap config berubah)
dart run flutter_native_splash:create

# 3. Generate app icon native (sekali, atau setiap ikon berubah)
dart run flutter_launcher_icons

# 4. Jalankan aplikasi
flutter run
```

Untuk mengganti sumber ikon: letakkan file baru di
`assets/icon/icon-app.jpeg`, lalu jalankan:

```bash
dart run tool/generate_brand_assets.dart
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

> **Catatan ikon:** file yang disediakan, `assets/icon/icon-app.jpeg`,
> berukuran 2816×1536 (banner landscape) dengan logo di tengah. Karena ikon
> launcher dan splash membutuhkan gambar persegi, `image_path` tetap menunjuk
> ke file tersebut, sedangkan `image_path_android`, `image_path_ios`, dan aset
> persegi lain diturunkan otomatis dari file yang sama oleh
> `tool/generate_brand_assets.dart`:
>
> - `assets/icon/icon-app-solid.png` — ikon persegi penuh (iOS, Android legacy,
>   web, Windows, macOS)
> - `assets/icon/icon-adaptive-foreground.png` — foreground adaptive icon
>   Android (logo putih transparan)
> - `assets/icon/splash-logo.png` — logo splash putih transparan
>
> Jika Anda sudah memiliki file ikon persegi (idealnya 1024×1024 PNG), cukup
> ubah `image_path` pada konfigurasi `flutter_launcher_icons` di `pubspec.yaml`.

### Konfigurasi splash screen

```yaml
flutter_native_splash:
  color: "#0B5D3B"          # hijau elegan
  color_dark: "#062E1D"
  image: assets/icon/splash-logo.png
  image_dark: assets/icon/splash-logo.png
  android: true
  ios: true
  web: true

  android_12:
    color: "#0B5D3B"
    color_dark: "#062E1D"
    image: assets/icon/splash-logo.png
    icon_background_color: "#0B5D3B"
    icon_background_color_dark: "#062E1D"
```

### Konfigurasi app icon

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon-app.jpeg"   # file ikon yang diminta
  image_path_android: "assets/icon/icon-app-solid.png"
  image_path_ios: "assets/icon/icon-app-solid.png"
  remove_alpha_ios: true
  adaptive_icon_background: "#0B5D3B"
  adaptive_icon_foreground: "assets/icon/icon-adaptive-foreground.png"
  web:
    generate: true
    image_path: "assets/icon/icon-app-solid.png"
    background_color: "#0B5D3B"
    theme_color: "#0B5D3B"
  windows:
    generate: true
    image_path: "assets/icon/icon-app-solid.png"
    icon_size: 256
  macos:
    generate: true
    image_path: "assets/icon/icon-app-solid.png"
```

> Perintah generate akan menimpa file ikon/splash hasil generate sebelumnya.
> Jika perubahan splash belum terlihat di perangkat, jalankan `flutter clean`
> lalu generate ulang splash dan icon.

## Struktur Proyek

```
lib/
├── main.dart                       # Entry point, init Hive, + MultiProvider
├── core/
│   ├── api_config.dart             # Base URL, timeout, ukuran halaman
│   ├── api_exception.dart          # Exception dengan pesan ramah pengguna
│   ├── app_theme.dart              # Tema Material 3 hijau/putih/emas
│   ├── fetch_result.dart           # Penanda hasil dari API atau cache
│   ├── formatters.dart             # Format angka 6.638
│   ├── json_utils.dart             # Parsing angka dari JSON
│   ├── safe_change_notifier.dart   # ChangeNotifier aman saat di-dispose
│   ├── text_normalizer.dart        # Normalisasi Arab/harakat untuk pencarian
│   └── topic_catalog.dart          # Daftar topik + hadis rujukannya
├── models/
│   ├── hadith_book.dart            # Kitab (name, slug, total) + toJson
│   ├── hadith.dart                 # Hadis (number, arab, terjemahan) + toJson
│   ├── hadith_page.dart            # Pagination + halaman daftar hadis
│   └── hadith_topic.dart           # Topik + referensi hadisnya
├── services/
│   ├── hadith_api_service.dart     # Semua pemanggilan HTTP ke API
│   ├── hadith_repository.dart      # Gabungan API + cache (network-first)
│   └── local_cache_service.dart    # Penyimpanan offline berbasis Hive
├── providers/
│   ├── books_provider.dart         # State daftar kitab
│   ├── hadith_list_provider.dart   # State daftar hadis + lazy loading
│   ├── hadith_detail_provider.dart # State detail hadis
│   ├── hadith_search_provider.dart # State pencarian + pembatalan
│   └── topic_provider.dart         # State hadis per topik
├── views/
│   ├── home_view.dart              # Beranda (kitab + deret topik)
│   ├── hadith_list_view.dart       # Daftar hadis per kitab
│   ├── hadith_detail_view.dart     # Detail hadis
│   ├── search_view.dart            # Pencarian nomor/kata kunci
│   ├── topics_view.dart            # Daftar seluruh topik
│   └── topic_detail_view.dart      # Hadis per topik
└── widgets/
    ├── kitab_card.dart
    ├── hadith_tile.dart
    ├── topic_card.dart
    ├── loading_state.dart
    └── status_message.dart
```

Arsitektur memakai pemisahan sederhana yang mirip Clean Architecture:

- **models** — representasi data API, tanpa dependensi UI.
- **services** — akses jaringan (`package:http`), penyimpanan lokal Hive, dan
  lapisan [HadithRepository] yang menggabungkan keduanya.
- **providers** — state management (`provider` + `ChangeNotifier`), tidak
  mengakses widget.
- **views/widgets** — hanya menampilkan state dan meneruskan aksi pengguna.

## Mode Offline (Penyimpanan Lokal Hive)

Library: `hive_ce` + `hive_ce_flutter` (fork Hive yang aktif, kompatibel
mundur dengan API Hive).

**Box yang dipakai** (`lib/services/local_cache_service.dart`):

| Box | Key | Value |
| --- | --- | --- |
| `hadis_books` | slug kitab | `{name, slug, total}` |
| `hadis_hadiths` | `{slug}_{nomor}` | `{number, arab, id, name, slug}` |

**Cara kerja** — strategi *network-first, cache fallback* di
`HadithRepository`:

1. Setiap permintaan (daftar kitab, halaman daftar hadis, detail hadis, hasil
   pencarian) dicoba ke API terlebih dahulu.
2. Hasil sukses **otomatis disimpan** ke Hive sebelum dikembalikan ke UI.
3. Bila API gagal (offline/server bermasalah), repository mengambil dari
   cache dan menandainya lewat `FetchResult.fromCache`.
4. Bila cache juga kosong, error aslinya diteruskan ke UI.

**Pembacaan offline:**

- Daftar kitab → seluruh isi box `hadis_books`.
- Daftar hadis per halaman → hadis kitab tersebut di-cache diurutkan per
  nomor lalu di-*slice* sesuai halaman (totalItems diisi jumlah benar-benar
  tersimpan agar UI tidak menjanjikan halaman yang belum ada).
- Detail hadis → pencarian langsung per `{slug}_{nomor}`.
- Pencarian kata kunci → pemindaian teks pada seluruh data tersimpan
  (normalisasi harakat Arab dipakai ulang).
- Halaman beranda menampilkan banner **Mode offline** ketika data datang dari
  cache.

**Dukungan lintas platform:** Hive menyimpan data di direktori dokumen
aplikasi (Android/iOS/desktop) dan IndexedDB di web.

## Topik / Kategori Hadis

Daftar topik ada di `lib/core/topic_catalog.dart`, tiap topik memuat
`keywords` (kata kunci pencarian lokal) dan `references` (kitab + nomor hadis
rujukan yang sudah diperiksa dari data API):

| Topik | Kata kunci contoh | Hadis rujukan |
| --- | --- | --- |
| Niat | niat, نيّة | Bukhari 1 |
| Iman | iman, beriman | Bukhari 7, Muslim 19 |
| Shalat | shalat, sholat, salat | Bukhari 497, Muslim 12 |
| Akhlak | akhlak, budi pekerti | Muslim 3941, Bukhari 3972 |
| Makanan & Minuman | makanan, minuman | Muslim 3556, Bukhari 235 |
| Sabar | sabar, kesabaran | Bukhari 1376, Muslim 1452 |
| Ilmu | ilmu, menuntut ilmu | Bukhari 77, Tirmidzi 2504 |
| Sedekah | sedekah, infak | Bukhari 53, Bukhari 4632 |

**Cara kerja `TopicProvider`:**

1. Ambil hadis rujukan topik yang **sudah tersimpan di Hive** dan tambahkan
   hasil pencarian `keywords` pada seluruh cache → langsung ditampilkan
   (cepat walau offline).
2. Rujukan yang belum ada diambil dari API berdasarkan kitab + nomor lalu
   disimpan ke Hive.
3. Bila sebagian rujukan gagal diambil, banner info menawarkan muat ulang
   ketika perangkat kembali daring.
4. Tombol di bagian bawah membuka halaman pencarian dengan kata kunci topik
   terisi otomatis.

## API yang Digunakan

| Endpoint | Kegunaan |
| --- | --- |
| `GET /hadith` | Daftar kitab/perawi dan jumlah hadis. |
| `GET /hadith/{slug}?page=1&limit=20` | Daftar hadis dengan pagination. |
| `GET /hadith/{slug}/{nomor}` | Detail satu hadis. |

**Tentang pencarian:** API ini tidak menyediakan endpoint pencarian. Karena itu:

- Input angka langsung diteruskan ke endpoint detail
  (`/hadith/{slug}/{nomor}`).
- Input kata kunci memindai endpoint daftar per halaman (500 hadis per
  permintaan) di kitab yang dipilih, mencocokkan teks Arab (harakat diabaikan)
  dan terjemahan, lalu berhenti setelah 20 hasil atau seluruh kitab selesai.
  Progres dan tombol **Hentikan** tersedia di halaman pencarian.

## Izin Jaringan Android

`android/app/src/main/AndroidManifest.xml` sudah memuat:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Izin ini wajib untuk build release agar aplikasi dapat memanggil API.

## Pengujian

```bash
flutter analyze
flutter test
```

Test unit mencakup format angka, parsing model, normalisasi teks Arab untuk
pencarian, serta perilaku cache offline (penyimpanan kitab, penyusunan ulang
halaman, pencarian lokal, dan kunci cache).

## Kredit

- Data: [renomureza/hadis-api-id](https://github.com/renomureza/hadis-api-id)
  (MIT), bersumber dari tafsirq.com.
