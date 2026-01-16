import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // PENTING: Untuk SystemUiOverlayStyle
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../controllers/promo_controller.dart';

// --- PALET WARNA MODERN ---
const Color kPrimaryColor = Color(0xFF2563EB); // Royal Blue
const Color kBackgroundColor = Color(0xFFF1F5F9); // Slate White
const Color kAccentColor = Color(0xFFF59E0B); // Amber/Gold
const Color kCardColor = Colors.white;
const Color kTextPrimary = Color(0xFF1E293B);
const Color kTextSecondary = Color(0xFF64748B);

class PromoView extends GetView<PromoController> {
  const PromoView({super.key});

  // State lokal untuk Tab Switcher (0 = Promo, 1 = History)
  static final RxInt _selectedTab = 0.obs;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PromoController>()) {
      Get.put(PromoController());
    }

    // 👇 PERBAIKAN DI SINI: Mengatur Status Bar Icon menjadi HITAM
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Latar status bar transparan
        statusBarIconBrightness: Brightness.dark, // Android: Icon Hitam
        statusBarBrightness:
            Brightness.light, // iOS: Icon Hitam (Background Terang)
      ),
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // 1. HEADER & SEARCH BAR
              _buildModernHeader(),

              // 2. STATISTIK DASHBOARD
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
                child: _buildSummaryStats(),
              ),

              // 3. TAB SWITCHER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSegmentedControl(),
              ),

              const SizedBox(height: 15),

              // 4. KONTEN SCROLLABLE
              Expanded(
                child: Obx(
                  () => _selectedTab.value == 0
                      ? _buildPromoContent() // List Promo
                      : _buildHistoryContent(), // List History
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET STATISTIK BARU (TOTAL PROMO & PESANAN) ---
  Widget _buildSummaryStats() {
    final int totalPesanan = 3;

    return Row(
      children: [
        // KARTU 1: TOTAL PROMO
        Expanded(
          child: _buildStatCard(
            title: "Total Promo",
            count: controller.vouchers.length.toString(),
            icon: Ionicons.ticket,
            colors: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
          ),
        ),
        const SizedBox(width: 15),
        // KARTU 2: TOTAL PESANAN
        Expanded(
          child: _buildStatCard(
            title: "Total Pesanan",
            count: totalPesanan.toString(),
            icon: Ionicons.bag_handle,
            colors: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required List<Color> colors,
  }) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(icon, size: 80, color: Colors.white.withOpacity(0.15)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  count,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET TAB SWITCHER ---
  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: [
            _buildTabButton("Voucher", 0),
            _buildTabButton("Riwayat", 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final bool isSelected = _selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectedTab.value = index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isSelected ? Colors.white : kTextSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // --- KONTEN HALAMAN PROMO ---
  Widget _buildPromoContent() {
    return RefreshIndicator(
      color: kPrimaryColor,
      onRefresh: () => controller.refreshData(),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryColor),
          );
        }

        if (controller.vouchers.isEmpty) {
          return _buildEmptyState(
            "Yah, Voucher Kosong!",
            "Nantikan promo menarik berikutnya.",
          );
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          itemCount: controller.vouchers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final voucher = controller.vouchers[index];
            return _ModernTicketItem(voucher: voucher);
          },
        );
      }),
    );
  }

  // --- KONTEN HALAMAN HISTORY ---
  Widget _buildHistoryContent() {
    final List<Map<String, dynamic>> dummyHistory = [
      {
        'id': 'ORD-8823',
        'date': '16 Jan 2026',
        'status': 'Sukses',
        'total': 'Rp 45.000',
        'items': 'Ayam Geprek, Es Teh',
      },
      {
        'id': 'ORD-8822',
        'date': '15 Jan 2026',
        'status': 'Proses',
        'total': 'Rp 120.000',
        'items': 'Paket Keluarga A',
      },
      {
        'id': 'ORD-8821',
        'date': '12 Jan 2026',
        'status': 'Batal',
        'total': 'Rp 32.000',
        'items': 'Nasi Goreng Spesial',
      },
    ];

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      itemCount: dummyHistory.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = dummyHistory[index];
        Color statusColor = Colors.green;
        Color statusBg = Colors.green.withOpacity(0.1);
        IconData statusIcon = Ionicons.checkmark_circle;

        if (item['status'] == 'Proses') {
          statusColor = Colors.orange;
          statusBg = Colors.orange.withOpacity(0.1);
          statusIcon = Ionicons.time;
        } else if (item['status'] == 'Batal') {
          statusColor = Colors.red;
          statusBg = Colors.red.withOpacity(0.1);
          statusIcon = Ionicons.close_circle;
        }

        return Container(
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kBackgroundColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Ionicons.receipt_outline,
                            color: kPrimaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['id'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: kTextPrimary,
                              ),
                            ),
                            Text(
                              item['date'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: kTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            item['status'] as String,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['items'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kTextSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      item['total'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: kPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- HEADER & SEARCH ---
  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const TextField(
                style: TextStyle(color: kTextPrimary),
                decoration: InputDecoration(
                  hintText: 'Cari diskon atau pesanan...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Ionicons.search_outline,
                    color: kPrimaryColor,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Ionicons.filter_outline, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              child: Icon(
                Ionicons.ticket_outline,
                size: 50,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: kTextSecondary)),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET TIKET MODERN ---
class _ModernTicketItem extends StatelessWidget {
  final dynamic voucher;

  const _ModernTicketItem({required this.voucher});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BAGIAN KIRI: Ikon & Dekorasi
            Container(
              width: 90,
              decoration: const BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Ionicons.gift, color: Colors.white, size: 32),
                    const SizedBox(height: 4),
                    Text(
                      "PROMO",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // BAGIAN TENGAH: Info Voucher
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      voucher['code'] ?? 'KODE',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: kTextPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Diskon Rp ${voucher['discount_amount']}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Ionicons.time_outline,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Berlaku hingga akhir bulan',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // BAGIAN KANAN: Garis Putus & Tombol
            CustomPaint(
              size: const Size(1, double.infinity),
              painter: _DashedLinePainter(),
            ),

            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: voucher['code'] ?? ''));
                Get.snackbar(
                  'Kode Disalin!',
                  'Gunakan kode saat checkout.',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: kPrimaryColor,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(20),
                  borderRadius: 12,
                  icon: const Icon(
                    Ionicons.checkmark_circle,
                    color: Colors.white,
                  ),
                  duration: const Duration(seconds: 2),
                );
              },
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Container(
                width: 70,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Ionicons.copy_outline,
                        color: kTextSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Salin",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: kTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PAINTER GARIS PUTUS-PUTUS ---
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 3, startY = 0;
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
