# 🛍️ Toko Pastel

Aplikasi mobile katalog produk bertema warna pastel, dibuat dengan **Flutter**. Data produk diambil dari [DummyJSON Products API](https://dummyjson.com/docs/products).

Proyek ini dibuat untuk memenuhi tugas pembuatan aplikasi mobile dengan ketentuan:

- Menggunakan API DummyJSON Products.
- Halaman depan menampilkan seluruh produk.
- Halaman detail produk, diakses dengan memilih produk dari halaman depan.
- Tombol search yang berfungsi.
- Tampilan menggunakan skema warna pastel.
- Dijalankan di handphone (bukan di browser).

## 🎥 Video Penjelasan & Demo

▶️ **[Tonton di YouTube](GANTI_DENGAN_LINK_YOUTUBE)**

## 👤 Identitas

|       |                           |
| ----- | ------------------------- |
| Nama  | GANTI_DENGAN_NAMA_LENGKAP |
| NIM   | GANTI_DENGAN_NIM          |
| Kelas | GANTI_DENGAN_KELAS        |

## ✨ Fitur

**Halaman depan**

- Menampilkan seluruh produk dalam grid 2 kolom.
- Setiap kartu menampilkan gambar, kategori, nama, harga, rating, dan label diskon.
- Warna latar kartu bergantian: peach, mint, lavender, sky, pink, dan butter.
- Status loading, pesan error dengan tombol _Coba lagi_, dan tampilan saat produk tidak ditemukan.

**Pencarian**

- Dijalankan dengan tombol search atau tombol Enter di keyboard.
- Tombol ✕ untuk menghapus kata pencarian dan menampilkan semua produk kembali.
- Hasil pencarian lama tidak menimpa hasil yang lebih baru.

**Halaman detail**

- Gambar produk yang bisa digeser, dengan indikator titik.
- Harga, harga coret, dan persentase diskon.
- Rating, kategori, brand, stok, berat, dan status ketersediaan.
- Deskripsi, tag, informasi garansi dan pengiriman, serta ulasan pembeli.
- Bar bawah berisi harga dan tombol _Tambah ke Keranjang_ (menampilkan notifikasi saja, belum ada fitur keranjang).

## 🖼️ Tampilan

| Halaman Depan                          | Pencarian                            | Detail Produk                     |
| -------------------------------------- | ------------------------------------ | --------------------------------- |
| ![Halaman depan](screenshots/home.png) | ![Pencarian](screenshots/search.png) | ![Detail](screenshots/detail.png) |

> Tambahkan screenshot ke folder `screenshots/` dengan nama di atas, atau hapus bagian ini kalau tidak dipakai.

## 🔌 API yang Digunakan

| Kegunaan         | Endpoint                                                     |
| ---------------- | ------------------------------------------------------------ |
| Semua produk     | `GET https://dummyjson.com/products?limit=0`                 |
| Pencarian produk | `GET https://dummyjson.com/products/search?q={kata}&limit=0` |
| Detail produk    | `GET https://dummyjson.com/products/{id}`                    |

Parameter `limit=0` dipakai supaya API mengembalikan seluruh produk. Tanpa parameter ini, API hanya memberikan 30 produk pertama.

## 🧰 Teknologi

- [Flutter](https://flutter.dev) dan Dart
- Package [`http`](https://pub.dev/packages/http) untuk memanggil API

## 📁 Struktur Kode

Seluruh kode ada di satu file, `lib/main.dart`:

| Bagian          | Fungsi                                                            |
| --------------- | ----------------------------------------------------------------- |
| `Warna`         | Kumpulan warna pastel yang dipakai di seluruh aplikasi            |
| `MainApp`       | Titik awal aplikasi dan pengaturan tema                           |
| `Product`       | Model data produk, dengan `fromJson` untuk mengubah JSON dari API |
| `HalamanList`   | Halaman depan: ambil data, search, dan grid produk                |
| `KartuProduk`   | Tampilan satu kotak produk di halaman depan                       |
| `HalamanDetail` | Halaman detail: ambil data satu produk dan tampilkan lengkap      |

## 🚀 Cara Menjalankan di HP

### Prasyarat

- [Flutter SDK](https://docs.flutter.dev/get-started/install) sudah terpasang. Cek dengan `flutter doctor`.
- HP Android dengan **Developer options** dan **USB debugging** aktif, atau emulator Android.
- Koneksi internet, karena data produk diambil dari API.

### Langkah

1. Clone repository ini:

   ```bash
   git clone GANTI_DENGAN_LINK_REPOSITORY
   cd NAMA_FOLDER_REPOSITORY
   ```

2. Install dependency:

   ```bash
   flutter pub get
   ```

3. Sambungkan HP ke komputer dengan kabel USB, lalu pastikan HP terdeteksi:

   ```bash
   flutter devices
   ```

4. Jalankan aplikasi:

   ```bash
   flutter run
   ```

### Membuat APK (opsional)

```bash
flutter build apk --release
```

File hasilnya ada di `build/app/outputs/flutter-apk/app-release.apk`.

> **Catatan:** agar aplikasi bisa mengakses internet pada build release, pastikan izin berikut ada di `android/app/src/main/AndroidManifest.xml`, di atas tag `<application>`:
>
> ```xml
> <uses-permission android:name="android.permission.INTERNET"/>
> ```

## 🎨 Palet Warna

| Warna    | Kode      | Dipakai untuk               |
| -------- | --------- | --------------------------- |
| Cream    | `#FFF8F3` | Latar halaman               |
| Lavender | `#B8A4E3` | Warna utama (tombol, harga) |
| Pink     | `#F7A8B8` | Label diskon                |
| Kuning   | `#F5C26B` | Rating                      |
| Peach    | `#FFE0D3` | Latar kartu                 |
| Mint     | `#D4F1E4` | Latar kartu                 |
| Sky      | `#D5EAF9` | Latar kartu                 |
| Butter   | `#FFF3C4` | Latar kartu                 |

Semua warna dikumpulkan di class `Warna` pada `lib/main.dart`, sehingga mudah diganti.

## 🙏 Sumber Data

Data produk dan gambar berasal dari [DummyJSON](https://dummyjson.com).
