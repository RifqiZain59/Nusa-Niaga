import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nusaniaga/app/modules/login/views/login_view.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    // Memastikan controller terinisialisasi
    Get.lazyPut(() => OnboardingController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Ikon status bar putih
        statusBarBrightness: Brightness.dark, // Ikon status bar putih (iOS)
        systemNavigationBarColor: Colors.transparent, // Nav bar transparan
        systemNavigationBarIconBrightness:
            Brightness.light, // Ikon nav bar putih
      ),
      child: Scaffold(
        // extendBody agar background gradient tembus sampai ke bawah navigation bar
        extendBody: true,
        body: Stack(
          children: [
            // 1. BACKGROUND GRADIENT (Premium Blue)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D47A1), // Biru gelap
                    Color(0xFF1976D2), // Biru medium
                    Color(0xFF42A5F5), // Biru muda
                  ],
                ),
              ),
            ),

            // 2. AKSEN IKON DEKORATIF (Floating Icons Transparan)
            _buildFloatingIcon(
              Icons.shopping_bag_outlined,
              top: 120,
              left: 50,
              size: 35,
            ),
            _buildFloatingIcon(
              Icons.stars_rounded,
              top: 80,
              right: 80,
              size: 25,
            ),
            _buildFloatingIcon(
              Icons.local_shipping_outlined,
              top: 350,
              right: 40,
              size: 45,
            ),
            _buildFloatingIcon(
              Icons.payments_outlined,
              bottom: 250,
              left: 40,
              size: 30,
            ),
            _buildFloatingIcon(
              Icons.storefront_outlined,
              bottom: 180,
              right: 60,
              size: 40,
            ),
            _buildFloatingIcon(
              Icons.auto_graph_outlined,
              top: 250,
              left: 30,
              size: 30,
            ),

            // 3. PAGE VIEW CONTENT
            PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.selectedPageIndex,
              itemCount: controller.onBoardingPages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // IKON UTAMA
                      Icon(
                        controller.onBoardingPages[index].imageAsset,
                        size: 110,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(height: 50),

                      // JUDUL
                      Text(
                        controller.onBoardingPages[index].title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // DESKRIPSI
                      Text(
                        controller.onBoardingPages[index].description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.7),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // 4. TOMBOL LEWATI (Kanan Atas)
            Positioned(
              top: 55,
              right: 15,
              child: TextButton(
                onPressed: () => Get.offAll(() => const LoginView()),
                child: Text(
                  "Lewati",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // 5. BOTTOM SECTION (Indicators & Next Button)
            // Jarak bottom dinaikkan ke 90 agar jauh dari area Navigasi HP
            Positioned(
              bottom: 90,
              left: 35,
              right: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots Indicator
                  Obx(
                    () => Row(
                      children: List.generate(
                        controller.onBoardingPages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 6),
                          height: 6,
                          width: controller.selectedPageIndex.value == index
                              ? 20
                              : 6,
                          decoration: BoxDecoration(
                            color: controller.selectedPageIndex.value == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // TOMBOL LANJUT / MULAI (Kecil & Elegan)
                  Obx(
                    () => SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        onPressed: controller.forwardAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0D47A1),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          controller.isLastPage ? "MULAI" : "LANJUT",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk membuat ikon melayang transparan di latar belakang
  Widget _buildFloatingIcon(
    IconData icon, {
    double? top,
    double? bottom,
    double? left,
    double? right,
    double size = 30,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Opacity(
        opacity: 0.08, // Sangat tipis agar tidak mengganggu konten utama
        child: Icon(icon, size: size, color: Colors.white),
      ),
    );
  }
}
