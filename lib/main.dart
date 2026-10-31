import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ============================================================
// 0. WARNA PASTEL
// Semua warna dikumpulkan di sini supaya mudah diganti
// ============================================================
class Warna {
  static const background = Color(0xFFFFF8F3); // cream
  static const teks = Color(0xFF4A4458);
  static const teksPudar = Color(0xFF8C869A);
  static const ungu = Color(0xFFB8A4E3); // lavender (warna utama)
  static const pink = Color(0xFFF7A8B8);
  static const kuning = Color(0xFFF5C26B);
  static const putih = Colors.white;
  static const bayangan = Color(0x40B8A4E3);

  // Warna latar kartu: peach, mint, lavender, sky, pink, butter
  static const List<Color> kartu = [
    Color(0xFFFFE0D3),
    Color(0xFFD4F1E4),
    Color(0xFFE3DAF7),
    Color(0xFFD5EAF9),
    Color(0xFFFBD8E6),
    Color(0xFFFFF3C4),
  ];

  // Ambil warna kartu berdasarkan urutan (diulang bergantian)
  static Color kartuKe(int i) => kartu[i % kartu.length];
}

// ============================================================
// 1. TITIK AWAL APLIKASI
// ============================================================
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Toko Pastel',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Warna.ungu),
        scaffoldBackgroundColor: Warna.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Warna.background,
          surfaceTintColor: Colors.transparent,
          foregroundColor: Warna.teks,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: Warna.teks,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      home: const HalamanList(),
    );
  }
}

// ============================================================
// 2. MODEL PRODUK
// Cetakan untuk menyimpan data satu produk dari API
// ============================================================
class Product {
  final int id;
  final String title;
  final String category;
  final double price;
  final double rating;
  final double discountPercentage;
  final String thumbnail;

  Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.rating,
    required this.discountPercentage,
    required this.thumbnail,
  });

  // Mengubah data JSON dari API menjadi objek Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      category: json['category'] ?? '',
      price: (json['price'] as num).toDouble(),
      rating: ((json['rating'] ?? 0) as num).toDouble(),
      discountPercentage: ((json['discountPercentage'] ?? 0) as num).toDouble(),
      thumbnail: json['thumbnail'],
    );
  }
}

// ============================================================
// 3. HALAMAN LIST (halaman utama)
// ============================================================
class HalamanList extends StatefulWidget {
  const HalamanList({super.key});

  @override
  State<HalamanList> createState() => _HalamanListState();
}

class _HalamanListState extends State<HalamanList> {
  // Tempat menyimpan daftar produk
  List<Product> dataList = [];

  // true = sedang loading, false = selesai
  bool isLoading = true;

  // Menyimpan pesan error (kosong kalau tidak ada error)
  String errorMessage = '';

  // Untuk membaca teks yang diketik di kolom Search
  TextEditingController searchController = TextEditingController();

  // Penanda permintaan terakhir, supaya hasil lama tidak menimpa hasil baru
  int permintaanKe = 0;

  // Dipanggil sekali saat halaman pertama kali dibuka
  @override
  void initState() {
    super.initState();
    ambilData(); // langsung ambil data dari API
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengambil data produk dari API
  Future<void> ambilData({String kataCari = ''}) async {
    final nomor = ++permintaanKe;

    // Tampilkan loading dulu
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Tentukan alamat API:
      // - kalau kolom search kosong -> ambil semua produk (limit=0 = tanpa batas)
      // - kalau ada isinya -> cari produk sesuai kata
      String alamat = 'https://dummyjson.com/products?limit=0';
      if (kataCari.isNotEmpty) {
        alamat =
            'https://dummyjson.com/products/search?q=${Uri.encodeQueryComponent(kataCari)}&limit=0';
      }

      // Kirim permintaan ke internet
      final response = await http.get(Uri.parse(alamat));

      // Abaikan kalau sudah ada permintaan yang lebih baru
      if (!mounted || nomor != permintaanKe) return;

      if (response.statusCode == 200) {
        // Berhasil: ubah teks JSON menjadi data Dart
        final data = jsonDecode(response.body);
        final List hasil = data['products'];

        setState(() {
          dataList = hasil.map((item) => Product.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Gagal memuat data';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted || nomor != permintaanKe) return;
      // Biasanya terjadi kalau tidak ada internet
      setState(() {
        errorMessage = 'Terjadi kesalahan, cek koneksi internet';
        isLoading = false;
      });
    }
  }

  // Dipanggil saat tombol search / Enter ditekan
  void cari() {
    FocusScope.of(context).unfocus(); // tutup keyboard
    ambilData(kataCari: searchController.text.trim());
  }

  // Kolom pencarian + tombol search
  Widget kolomSearch() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.only(left: 18, right: 6),
      height: 52,
      decoration: BoxDecoration(
        color: Warna.putih,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Warna.bayangan,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: Warna.teks),
              decoration: const InputDecoration(
                hintText: 'Cari produk...',
                hintStyle: TextStyle(color: Warna.teksPudar),
                border: InputBorder.none,
              ),
              onChanged: (_) =>
                  setState(() {}), // supaya tombol X muncul/hilang
              onSubmitted: (_) => cari(),
            ),
          ),
          // Tombol hapus teks (X), hanya muncul kalau ada teks
          if (searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, size: 20, color: Warna.teksPudar),
              onPressed: () {
                searchController.clear();
                setState(() {});
                ambilData(); // kembali menampilkan semua produk
              },
            ),
          // Tombol search
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Warna.ungu,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: cari,
            ),
          ),
        ],
      ),
    );
  }

  // Menentukan apa yang tampil di bawah kolom Search
  Widget tampilanIsi() {
    // Kalau sedang loading -> tampilkan lingkaran berputar
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Warna.ungu));
    }

    // Kalau ada error -> tampilkan pesan error + tombol coba lagi
    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😢', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 8),
            Text(errorMessage, style: const TextStyle(color: Warna.teksPudar)),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Warna.ungu,
                foregroundColor: Colors.white,
              ),
              onPressed: cari,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    // Kalau data kosong -> beri tahu user
    if (dataList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🫧', style: TextStyle(fontSize: 44)),
            SizedBox(height: 8),
            Text(
              'Produk tidak ditemukan',
              style: TextStyle(color: Warna.teksPudar),
            ),
          ],
        ),
      );
    }

    // Kalau semua aman -> tampilkan daftar produk dalam 2 kolom
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: dataList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.66,
      ),
      itemBuilder: (context, index) {
        final product = dataList[index];

        return KartuProduk(
          product: product,
          index: index,
          // Saat item ditekan, pindah ke halaman detail
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    HalamanDetail(id: product.id, index: index),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo 👋',
                    style: TextStyle(fontSize: 14, color: Warna.teksPudar),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Temukan produk favoritmu',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Warna.teks,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Kolom pencarian
            kolomSearch(),

            // Jumlah produk
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 8),
              child: Text(
                isLoading ? 'Memuat...' : '${dataList.length} produk',
                style: const TextStyle(fontSize: 13, color: Warna.teksPudar),
              ),
            ),

            // Bagian daftar produk
            Expanded(child: tampilanIsi()),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 3b. KARTU PRODUK (satu kotak produk di halaman list)
// ============================================================
class KartuProduk extends StatelessWidget {
  final Product product;
  final int index;
  final VoidCallback onTap;

  const KartuProduk({
    super.key,
    required this.product,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Warna.putih,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Warna.bayangan,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian gambar dengan latar warna pastel
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: Warna.kartuKe(index),
                      padding: const EdgeInsets.all(12),
                      child: Image.network(
                        product.thumbnail,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.image_not_supported,
                              color: Warna.teksPudar,
                            ),
                      ),
                    ),
                  ),
                  // Label diskon
                  if (product.discountPercentage > 0)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Warna.pink,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '-${product.discountPercentage.round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Bagian informasi
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Warna.teksPudar,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Warna.teks,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Warna.ungu,
                        ),
                      ),
                      Text(
                        '★ ${product.rating}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Warna.kuning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 4. HALAMAN DETAIL
// Menampilkan informasi lengkap satu produk
// ============================================================
class HalamanDetail extends StatefulWidget {
  // id produk yang dikirim dari halaman list
  final int id;

  // urutan produk di list (dipakai untuk menentukan warna latar)
  final int index;

  const HalamanDetail({super.key, required this.id, this.index = 0});

  @override
  State<HalamanDetail> createState() => _HalamanDetailState();
}

class _HalamanDetailState extends State<HalamanDetail> {
  // Menyimpan data produk (null artinya belum ada)
  Map<String, dynamic>? produk;

  bool isLoading = true;
  String errorMessage = '';

  // Nomor gambar yang sedang tampil (untuk titik-titik indikator)
  int gambarKe = 0;

  @override
  void initState() {
    super.initState();
    ambilDetail();
  }

  // Mengambil data 1 produk berdasarkan id
  Future<void> ambilDetail() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://dummyjson.com/products/${widget.id}'),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          produk = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Gagal memuat detail produk';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Terjadi kesalahan, cek koneksi internet';
        isLoading = false;
      });
    }
  }

  // Label kecil berwarna (kategori, brand, tag)
  Widget chip(String teks, Color warna) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: warna,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        teks,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Warna.teks,
        ),
      ),
    );
  }

  // Kotak statistik kecil (stok, berat, status)
  Widget kotakStat(String label, String nilai, Color warna) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: warna,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              nilai,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Warna.teks,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Warna.teksPudar),
            ),
          ],
        ),
      ),
    );
  }

  // Satu baris informasi (kiri: judul, kanan: isi)
  Widget barisInfo(String judul, String isi) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            style: const TextStyle(fontSize: 13, color: Warna.teksPudar),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              isi,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Warna.teks,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget judulBagian(String teks) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        teks,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: Warna.teks,
        ),
      ),
    );
  }

  // Menentukan apa yang tampil di halaman detail
  Widget tampilanIsi() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Warna.ungu));
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😢', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 8),
            Text(errorMessage, style: const TextStyle(color: Warna.teksPudar)),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Warna.ungu,
                foregroundColor: Colors.white,
              ),
              onPressed: ambilDetail,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    // ---- Siapkan data dari JSON ----
    final p = produk!;
    final List daftarGambar = (p['images'] as List?) ?? [];
    final List gambar = daftarGambar.isEmpty ? [p['thumbnail']] : daftarGambar;

    final double harga = (p['price'] as num).toDouble();
    final double diskon = ((p['discountPercentage'] ?? 0) as num).toDouble();
    final double hargaAsli = diskon > 0 && diskon < 100
        ? harga / (1 - diskon / 100)
        : harga;

    final String brand = (p['brand'] ?? '').toString();
    final List tags = (p['tags'] as List?) ?? [];
    final List ulasan = (p['reviews'] as List?) ?? [];

    // Daftar informasi tambahan (yang kosong tidak ditampilkan)
    final List<List<dynamic>> info = [
      ['Garansi', p['warrantyInformation']],
      ['Pengiriman', p['shippingInformation']],
      ['Pengembalian', p['returnPolicy']],
      ['Min. pembelian', p['minimumOrderQuantity']],
    ];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Gambar produk (bisa digeser) ----
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Warna.kartuKe(widget.index),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      PageView.builder(
                        itemCount: gambar.length,
                        onPageChanged: (i) => setState(() => gambarKe = i),
                        itemBuilder: (context, i) => Padding(
                          padding: const EdgeInsets.all(24),
                          child: Image.network(
                            gambar[i],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.image_not_supported,
                                  color: Warna.teksPudar,
                                ),
                          ),
                        ),
                      ),
                      // Titik indikator
                      if (gambar.length > 1)
                        Positioned(
                          bottom: 14,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(gambar.length, (i) {
                              final aktif = i == gambarKe;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: aktif ? 20 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: aktif
                                      ? Colors.white
                                      : const Color(0xB3FFFFFF),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ---- Kategori & brand ----
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    chip('${p['category']}', const Color(0xFFE3DAF7)),
                    if (brand.isNotEmpty) chip(brand, const Color(0xFFD5EAF9)),
                  ],
                ),
                const SizedBox(height: 10),

                // ---- Nama produk ----
                Text(
                  '${p['title']}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Warna.teks,
                  ),
                ),
                const SizedBox(height: 6),

                // ---- Rating ----
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '★ ${p['rating']}',
                        style: const TextStyle(
                          color: Warna.kuning,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      TextSpan(
                        text: '  ·  ${ulasan.length} ulasan',
                        style: const TextStyle(color: Warna.teksPudar),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ---- Harga ----
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '\$$harga',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Warna.ungu,
                      ),
                    ),
                    if (diskon > 0) ...[
                      const SizedBox(width: 12),
                      Text(
                        '\$${hargaAsli.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Warna.teksPudar,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Warna.pink,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '-${diskon.round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 18),

                // ---- Stok, berat, status ----
                Row(
                  children: [
                    kotakStat('Stok', '${p['stock']}', const Color(0xFFD4F1E4)),
                    kotakStat(
                      'Berat',
                      '${p['weight'] ?? '-'}',
                      const Color(0xFFFFF3C4),
                    ),
                    kotakStat(
                      'Status',
                      '${p['availabilityStatus'] ?? '-'}',
                      const Color(0xFFFBD8E6),
                    ),
                  ],
                ),

                // ---- Deskripsi ----
                judulBagian('Deskripsi'),
                Text(
                  '${p['description']}',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Warna.teksPudar,
                  ),
                ),

                // ---- Tag ----
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (int i = 0; i < tags.length; i++)
                        chip('#${tags[i]}', Warna.kartuKe(i + 1)),
                    ],
                  ),
                ],

                // ---- Informasi tambahan ----
                judulBagian('Informasi'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Warna.putih,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      for (final baris in info)
                        if (baris[1] != null)
                          barisInfo(baris[0], baris[1].toString()),
                    ],
                  ),
                ),

                // ---- Ulasan ----
                if (ulasan.isNotEmpty) ...[
                  judulBagian('Ulasan'),
                  for (int i = 0; i < ulasan.length; i++)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Warna.kartuKe(i + 2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${ulasan[i]['reviewerName']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Warna.teks,
                                ),
                              ),
                              Text(
                                '★' * (ulasan[i]['rating'] as num).toInt(),
                                style: const TextStyle(color: Warna.kuning),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${ulasan[i]['comment']}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Warna.teks,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),

        // ---- Bar bawah: harga + tombol ----
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
            color: Warna.putih,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Warna.bayangan,
                blurRadius: 12,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Harga',
                        style: TextStyle(fontSize: 12, color: Warna.teksPudar),
                      ),
                      Text(
                        '\$$harga',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Warna.teks,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Warna.ungu,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ditambahkan ke keranjang 🛒'),
                        backgroundColor: Warna.ungu,
                      ),
                    );
                  },
                  child: const Text(
                    'Tambah ke Keranjang',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: tampilanIsi(),
    );
  }
}
