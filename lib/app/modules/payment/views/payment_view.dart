import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nusaniaga/app/modules/home/views/home_view.dart';

// --- PERUBAHAN: Menambahkan import untuk HomeView ---
// Asumsi path HomeView berada di '../home/views/home_view.dart'
// Harap sesuaikan path ini jika struktur file Anda berbeda.
// import 'package:namaproyek/app/modules/home/views/home_view.dart'; // Jika menggunakan path absolut

import '../controllers/payment_controller.dart';

class PaymentView extends GetView<PaymentController> {
  const PaymentView({super.key});

  // Fungsi baru untuk menampilkan kotak dialog konfirmasi (floating box)
  void _showConfirmationDialog(String parentMethod, String selectedOption) {
    Get.back(); // Pastikan modal sebelumnya tertutup

    // Observable untuk melacak status upload gambar (simulasi)
    RxString uploadedFileName = ''.obs;

    // Konten yang berubah berdasarkan pilihan
    String dialogTitle;
    Widget dialogContent;

    // Widget untuk input Upload Gambar yang akan digunakan di kedua opsi
    Widget uploadWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        const Text(
          'Upload Bukti Pembayaran:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // SIMULASI: Dalam aplikasi nyata, ini akan memanggil image_picker/file_picker
                    if (uploadedFileName.value.isEmpty) {
                      uploadedFileName.value =
                          'bukti_${DateTime.now().millisecondsSinceEpoch}.jpg';
                      Get.snackbar(
                        'Upload Berhasil',
                        'File berhasil dimuat.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    } else {
                      uploadedFileName.value = '';
                    }
                  },
                  icon: Icon(
                    uploadedFileName.value.isEmpty
                        ? Icons.upload_file
                        : Icons.refresh,
                    color: Colors.white,
                  ),
                  label: Text(
                    uploadedFileName.value.isEmpty
                        ? 'Pilih Gambar Bukti'
                        : 'Ubah Gambar',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: uploadedFileName.value.isEmpty
                        ? Colors.blue
                        : Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => uploadedFileName.value.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'File Terpilih: ${uploadedFileName.value}',
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );

    if (selectedOption == 'Transfer Bank') {
      dialogTitle = 'Detail Transfer Bank ($parentMethod)';
      dialogContent = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lakukan transfer ke rekening berikut:',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 10),
          // Placeholder Nomor Rekening
          const Text(
            'Nomor Rekening Tujuan:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SelectableText(
            '1234 5678 9012 (BCA)',
            style: TextStyle(color: Colors.blue, fontSize: 16),
          ),
          const SizedBox(height: 5),
          // Placeholder Nama
          const Text(
            'Nama Penerima:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'PT. Mitra Digital',
            style: TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 10),
          const Text(
            'Jumlah yang harus dibayar: Rp XXX.XXX',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          uploadWidget, // Masukkan widget upload
        ],
      );
    } else {
      // Opsi QRIS
      dialogTitle = 'QR Code ($parentMethod)';
      dialogContent = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Silakan pindai QR Code di bawah untuk melanjutkan pembayaran.',
            style: TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          // Placeholder untuk QR Code
          Container(
            width: 150,
            height: 150,
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.qr_code_2, size: 80, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Jumlah Pembayaran: Rp XXX.XXX',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          uploadWidget, // Masukkan widget upload
        ],
      );
    }

    Get.defaultDialog(
      title: dialogTitle,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: dialogContent,
      ),
      backgroundColor: Colors.white,
      titleStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      radius: 15,
      // Tombol Aksi
      actions: [
        TextButton(
          onPressed: () {
            // Aksi nyata: Kirim data ke server
            if (uploadedFileName.value.isEmpty) {
              Get.snackbar(
                'Perhatian',
                'Harap upload bukti pembayaran terlebih dahulu.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.shade100,
              );
            } else {
              // --- PERUBAHAN: Pindah ke HomeView dan hapus stack navigasi ---
              Get.offAll(() => const HomeView());
              Get.snackbar(
                'Berhasil',
                'Pembayaran sedang diproses! Anda dialihkan ke halaman utama.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.shade100,
              );
            }
          },
          child: const Text(
            'Konfirmasi Pembayaran',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Batal', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  // Fungsi untuk menampilkan kotak dialog pilihan utama (modal bottom sheet)
  void _showPaymentOptions(BuildContext context, String methodName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0),
              ),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Wrap(
              children: <Widget>[
                // Judul Modal
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Text(
                      'Pilih Metode Pembayaran $methodName',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Divider(),

                // Opsi 1: Transfer
                ListTile(
                  leading: const Icon(Icons.compare_arrows),
                  title: const Text('Transfer Bank'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showConfirmationDialog(methodName, 'Transfer Bank');
                  },
                ),

                // Opsi 2: QRIS
                ListTile(
                  leading: const Icon(Icons.qr_code_2),
                  title: const Text('QRIS (Scan QR)'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showConfirmationDialog(methodName, 'QRIS');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Payment Method',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        centerTitle: true,
        actions: const [],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: Column(
          children: [
            _buildPaymentMethodItem(
              context: context,
              assetPath: 'assets/icon/gopay.png',
              title: 'GoPay',
              subtitle: '',
            ),
            const SizedBox(height: 10),
            _buildPaymentMethodItem(
              context: context,
              assetPath: 'assets/icon/shopeepay.png',
              title: 'ShopeePay',
              subtitle: '',
            ),
            const SizedBox(height: 15),
            _buildAddPaymentMethod(),
          ],
        ),
      ),
    );
  }

  // Widget pembantu untuk membangun setiap item metode pembayaran
  Widget _buildPaymentMethodItem({
    required BuildContext context,
    required String assetPath,
    Color iconBgColor = Colors.transparent,
    required String title,
    required String subtitle,
    bool showWarning = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 5.0,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1.0),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Image.asset(assetPath, fit: BoxFit.contain),
            ),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: (subtitle.isEmpty) ? 17 : 16,
          ),
        ),
        subtitle: subtitle.isNotEmpty
            ? Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              )
            : null,
        trailing: showWarning
            ? const Icon(Icons.info_outline, color: Colors.grey, size: 20)
            : const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        onTap: () {
          _showPaymentOptions(context, title);
        },
      ),
    );
  }

  // Widget pembantu untuk membangun item 'Add Payment Method'
  Widget _buildAddPaymentMethod() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 5.0,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1.0),
          ),
          child: const Center(
            child: Icon(Icons.add, color: Colors.black, size: 24),
          ),
        ),
        title: const Text(
          'Add Payment Method',
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 16,
        ),
        onTap: () {
          Get.snackbar('Tambah Metode', 'Halaman tambah metode pembayaran');
        },
      ),
    );
  }
}
