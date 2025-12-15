import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async'; // Diperlukan untuk Timer

class DetailPoinView extends StatefulWidget {
  const DetailPoinView({super.key});

  @override
  State<DetailPoinView> createState() => _DetailPoinViewState();
}

class _DetailPoinViewState extends State<DetailPoinView> {
  static const Color primaryColor = Color(0xFF4CAF50); // Hijau

  // Variabel State
  int userPoints = 500; // Poin pengguna dinamis
  static const int redeemCost = 100; // Poin yang dibutuhkan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // WARNA BACKGROUND SCAFFOLD DIUBAH MENJADI PUTIH
      backgroundColor: Colors.white,

      // --- APP BAR DIKEMBALIKAN ---
      appBar: AppBar(
        // WARNA APP BAR DIUBAH MENJADI PUTIH
        backgroundColor: Colors.white,
        surfaceTintColor: Colors
            .white, // Penting untuk menghilangkan bayangan/warna default pada Material 3
        // Tombol kembali di sebelah kiri
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        // Judul di tengah
        title: const Text(
          'Detail Promo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        // Tambahkan elevasi tipis agar terlihat terpisah dari body jika perlu (opsional)
        elevation: 1,
      ),
      // --- END APP BAR ---

      // Konten utama halaman (BODY KEMBALI NORMAL TANPA STACK)
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Bagian Atas: Kartu Promo ---
            _buildPromoCard(),
            const SizedBox(height: 24.0),
            // --- Bagian Bawah: Cara Menukarkan Poin ---
            _buildHowToGetPromoSection(),
            // Jarak tambahan agar konten tidak tertutup oleh bottomNavigationBar
            const SizedBox(height: 100.0),
          ],
        ),
      ),

      // Bilah Bawah (bottomNavigationBar) tetap dipertahankan
      bottomNavigationBar: _buildBottomRedeemBar(context),
    );
  }

  // FUNGSI DIALOG KODE VOUCHER (QR/Barcode)
  void _showVoucherCodeDialog(BuildContext context) {
    const int initialDurationSeconds = 1800;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _VoucherTimerDialog(
          initialDurationSeconds: initialDurationSeconds,
        );
      },
    );
  }

  // FUNGSI DIALOG KONFIRMASI
  void _showRedeemConfirmationDialog(BuildContext context) {
    final bool isPointsSufficient = userPoints >= redeemCost;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Konfirmasi Penukaran",
            style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Siap menukar point: $redeemCost Poin",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              if (!isPointsSufficient)
                const Text(
                  "Poin Anda tidak cukup untuk penukaran ini.",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (isPointsSufficient)
                Text(
                  "Anda akan kehilangan $redeemCost Poin. Poin Anda saat ini: $userPoints. Lanjutkan penukaran?",
                  style: const TextStyle(color: Colors.black87),
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.black54),
              ),
            ),
            ElevatedButton(
              onPressed: isPointsSufficient
                  ? () {
                      Navigator.of(context).pop();

                      setState(() {
                        userPoints -= redeemCost;
                      });

                      _showVoucherCodeDialog(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tukar Sekarang'),
            ),
          ],
        );
      },
    );
  }

  // Widget _buildBottomRedeemBar
  Widget _buildBottomRedeemBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Poin Saya',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 20, color: primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      '$userPoints Poin',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                _showRedeemConfirmationDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: const Text(
                'Tukar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildPromoCard
  Widget _buildPromoCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 16,
                  color: Colors.orange,
                ),
                SizedBox(width: 4),
                Text(
                  'Promo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          const Text(
            '10% off',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              'assets/images/promo_banner.jpg',
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  // Widget _buildHowToGetPromoSection
  Widget _buildHowToGetPromoSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Cara Menukarkan Poin',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16.0),
          _buildPromoStep(
            'Langkah 1: Pastikan Poin Cukup',
            'Cek total Poin Saya di bagian bawah halaman. Penukaran ini membutuhkan $redeemCost Poin.',
          ),
          _buildPromoStep(
            'Langkah 2: Klik Tombol "Tukar"',
            'Tekan tombol "Tukar" di bilah navigasi bawah.',
          ),
          _buildPromoStep(
            'Langkah 3: Konfirmasi Penukaran',
            'Anda akan diminta konfirmasi. Pastikan Anda benar-benar ingin menukar $redeemCost Poin.',
          ),
          _buildPromoStep(
            'Langkah 4: Pindai Kode',
            'Kode voucher akan muncul. Tunjukkan kode tersebut kepada kasir untuk memproses diskon.',
          ),
        ],
      ),
    );
  }

  // Widget _buildPromoStep
  Widget _buildPromoStep(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Icon(Icons.circle, size: 8, color: primaryColor),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- KELAS BARU: DIALOG VOUCHER DENGAN TIMER (StatefulWidget) ---
class _VoucherTimerDialog extends StatefulWidget {
  final int initialDurationSeconds;

  const _VoucherTimerDialog({required this.initialDurationSeconds});

  @override
  State<_VoucherTimerDialog> createState() => _VoucherTimerDialogState();
}

class _VoucherTimerDialogState extends State<_VoucherTimerDialog> {
  static const Color primaryColor = Color(0xFF4CAF50);
  late Timer _timer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialDurationSeconds;
    startTimer();
  }

  // Memulai Timer Hitung Mundur
  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Pastikan timer dihentikan
    super.dispose();
  }

  // Fungsi untuk memformat detik menjadi MM:SS
  String formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    const String voucherCode = "VCR-2025-ABCD";

    final bool isExpired = _remainingSeconds == 0;
    final Color timerColor = isExpired ? Colors.red : primaryColor;
    final String timerValue = formatDuration(_remainingSeconds);

    // Menentukan teks label berdasarkan status
    final String timerLabel = isExpired ? "Kode Ini" : "Kadaluwarsa dalam";
    final String fullTimerText = isExpired ? "KADALUWARSA" : timerValue;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Center(
        child: Text(
          isExpired ? "Kode Kadaluwarsa!" : "Voucher Anda Siap!",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: timerColor,
            fontSize: 20,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Text(
            "Tunjukkan kode ini kepada kasir untuk memproses diskon.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 20),

          // Placeholder QR Code/Barcode
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                Icons.qr_code_2,
                size: 150,
                color: isExpired ? Colors.grey : Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            voucherCode,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: isExpired ? Colors.grey : Colors.black,
            ),
          ),

          const SizedBox(height: 20),

          // Bagian Timer Hitung Mundur
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time, size: 16, color: timerColor),
              const SizedBox(width: 5),

              // Teks Label Statis
              Text(
                '$timerLabel ',
                style: TextStyle(
                  color: timerColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Teks Nilai Timer (Angka Mundur)
              Text(
                fullTimerText,
                style: TextStyle(
                  color: timerColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Selesai'),
          ),
        ),
      ],
    );
  }
}
