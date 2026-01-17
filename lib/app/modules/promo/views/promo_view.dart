import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ionicons/ionicons.dart';
import '../controllers/promo_controller.dart';

// --- PALET WARNA ---
const Color kPrimaryColor = Color(0xFF2563EB);
const Color kBackgroundColor = Color(0xFFF1F5F9);
const Color kCardColor = Colors.white;
const Color kTextPrimary = Color(0xFF1E293B);
const Color kTextSecondary = Color(0xFF64748B);

class PromoView extends GetView<PromoController> {
  const PromoView({super.key});

  String formatRupiah(dynamic number) {
    if (number == null) return "Rp 0";
    try {
      double valDouble = double.tryParse(number.toString()) ?? 0;
      int val = valDouble.toInt();
      String str = val.toString();
      RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      return "Rp ${str.replaceAllMapped(reg, (Match m) => '${m[1]}.')}";
    } catch (e) {
      return "Rp 0";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PromoController>()) {
      Get.put(PromoController());
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildModernHeader(),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return _buildStatSkeleton();
                  }
                  return _buildStatCard(
                    title: "Voucher Aktif",
                    count: "${controller.vouchers.length} Tersedia",
                    icon: Ionicons.ticket,
                    colors: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                  );
                }),
              ),

              const SizedBox(height: 5),

              Expanded(
                // [FITUR BARU] Tarik untuk Refresh
                child: RefreshIndicator(
                  color: kPrimaryColor,
                  backgroundColor: Colors.white,
                  onRefresh: () => controller.refreshData(),
                  child: Obx(() {
                    // 1. Loading Awal (Tampilkan Efek Blur/Shimmer)
                    if (controller.isLoading.value) {
                      return _buildShimmerList();
                    }

                    // 2. Data Kosong (Tampilkan Empty State yang Scrollable)
                    if (controller.vouchers.isEmpty) {
                      return _buildScrollableEmptyState(
                        "Yah, Voucher Kosong!",
                        "Belum ada promo aktif saat ini.",
                      );
                    }

                    // 3. Data Ada (Tampilkan List)
                    return ListView.separated(
                      physics:
                          const AlwaysScrollableScrollPhysics(), // Wajib agar bisa ditarik
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                      itemCount: controller.vouchers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final doc = controller.vouchers[index];
                        final data = doc.data() as Map<String, dynamic>;

                        String code = data['code'] ?? 'N/A';
                        dynamic amount = data['discount_amount'] ?? 0;

                        return _ModernTicketItem(
                          code: code,
                          discount: formatRupiah(amount),
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET SKELETON / SHIMMER LIST ---
  Widget _buildShimmerList() {
    return ListView.separated(
      physics:
          const NeverScrollableScrollPhysics(), // Kunci scroll saat loading
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return const _SkeletonTicketItem();
      },
    );
  }

  Widget _buildStatSkeleton() {
    return Container(
      height: 110,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.grey[300], // Warna dasar skeleton
      ),
    );
  }

  // --- WIDGET EMPTY STATE YANG BISA DI-SCROLL ---
  // Penting: Agar RefreshIndicator tetap jalan saat data kosong
  Widget _buildScrollableEmptyState(String title, String subtitle) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: constraints.maxHeight - 50, // Tinggi layar minus padding
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    Text(
                      subtitle,
                      style: const TextStyle(color: kTextSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- WIDGET LAINNYA ---
  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required List<Color> colors,
  }) {
    return Container(
      height: 110,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            bottom: -15,
            child: Icon(icon, size: 100, color: Colors.white.withOpacity(0.15)),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
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
                decoration: InputDecoration(
                  hintText: 'Cari kode promo...',
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
        ],
      ),
    );
  }
}

// --- WIDGET ITEM SHIMMER (SKELETON) ---
class _SkeletonTicketItem extends StatefulWidget {
  const _SkeletonTicketItem();

  @override
  State<_SkeletonTicketItem> createState() => _SkeletonTicketItemState();
}

class _SkeletonTicketItemState extends State<_SkeletonTicketItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _colorAnimation = ColorTween(
      begin: Colors.grey[200],
      end: Colors.grey[100],
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          height: 100,
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 90,
                decoration: BoxDecoration(
                  color: _colorAnimation.value,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 20,
                        width: 120,
                        color: _colorAnimation.value,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 14,
                        width: 80,
                        color: _colorAnimation.value,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 150,
                        color: _colorAnimation.value,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Container(
                  height: 30,
                  width: 60,
                  decoration: BoxDecoration(
                    color: _colorAnimation.value,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- WIDGET ITEM ASLI ---
class _ModernTicketItem extends StatelessWidget {
  final String code;
  final String discount;

  const _ModernTicketItem({required this.code, required this.discount});

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
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Ionicons.gift, color: Colors.white, size: 32),
                    SizedBox(height: 4),
                    Text(
                      "PROMO",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: kTextPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Potongan $discount',
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
                          Ionicons.infinite_outline,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Berlaku untuk semua member',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: code));
                Get.snackbar(
                  'Disalin!',
                  'Kode $code siap digunakan.',
                  backgroundColor: kPrimaryColor,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                  margin: const EdgeInsets.all(20),
                  borderRadius: 12,
                );
              },
              child: Container(
                width: 60,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Colors.grey[200]!,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Ionicons.copy_outline,
                      color: kTextSecondary,
                      size: 20,
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Salin",
                      style: TextStyle(fontSize: 10, color: kTextSecondary),
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
