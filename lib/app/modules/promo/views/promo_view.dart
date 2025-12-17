import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../controllers/promo_controller.dart';

// Warna Biru Utama (Konsisten dengan tema proyek)
const Color primaryBlue = Color(0xFF1976D2);

class PromoView extends GetView<PromoController> {
  const PromoView({super.key});

  @override
  Widget build(BuildContext context) {
    // Memastikan PromoController terdaftar di GetX memori
    if (!Get.isRegistered<PromoController>()) {
      Get.put(PromoController());
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header: Pencarian dan Filter
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari Promo atau Diskon...',
                          border: InputBorder.none,
                          prefixIcon: Icon(Ionicons.search, color: Colors.grey),
                          prefixIconConstraints: BoxConstraints(minWidth: 30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Ionicons.options, color: Colors.white),
                      onPressed: () {
                        // Aksi filter tambahan
                      },
                    ),
                  ),
                ],
              ),
            ),

            // 2. Banner Promo Utama
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _PromoBannerWidget(),
            ),

            const Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '⚡️ Daftar Voucher Belanja',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 3. Daftar Voucher (Menggunakan Obx)
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.vouchers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Ionicons.gift_outline,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Belum ada voucher tersedia.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.refreshData(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    itemCount: controller.vouchers.length,
                    itemBuilder: (context, index) {
                      final voucher = controller.vouchers[index];
                      // InkWell dihapus atau dihilangkan fungsinya karena tidak ada DetailView
                      return _VoucherListItem(voucher: voucher);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Widget Card Item Voucher ---
class _VoucherListItem extends StatelessWidget {
  final dynamic voucher;

  const _VoucherListItem({required this.voucher});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Ionicons.ticket, color: primaryBlue, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voucher['code'] ?? 'KODE',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Diskon Rp ${voucher['discount_amount']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Ionicons.checkmark_circle,
                      size: 14,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Voucher Aktif',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Ionicons.copy_outline,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: voucher['code'] ?? ''));
              Get.snackbar(
                'Berhasil Disalin',
                'Kode ${voucher['code']} siap digunakan.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: primaryBlue,
                colorText: Colors.white,
                margin: const EdgeInsets.all(10),
                duration: const Duration(seconds: 2),
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- Widget Banner Atas ---
class _PromoBannerWidget extends StatelessWidget {
  const _PromoBannerWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryBlue, Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DISKON BELANJA!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Gunakan kode voucher aktif untuk menikmati potongan harga spesial di Nusa Niaga.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
