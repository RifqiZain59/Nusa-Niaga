import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nusaniaga/app/modules/login/views/login_view.dart';

class OnboardingController extends GetxController {
  var selectedPageIndex = 0.obs;
  var pageController = PageController();
  bool get isLastPage => selectedPageIndex.value == onBoardingPages.length - 1;

  // Data Dummy untuk Onboarding (Bisa diganti dengan gambar asset nanti)
  final List<OnboardingInfo> onBoardingPages = [
    OnboardingInfo(
      imageAsset: Icons.store_mall_directory_rounded,
      title: 'Selamat Datang di Nusa Niaga',
      description:
          'Platform terbaik untuk mengelola bisnis dan toko Anda secara digital dan efisien.',
    ),
    OnboardingInfo(
      imageAsset: Icons.analytics_rounded,
      title: 'Analisa Penjualan',
      description:
          'Pantau keuntungan dan stok barang secara real-time dengan grafik yang mudah dipahami.',
    ),
    OnboardingInfo(
      imageAsset: Icons.rocket_launch_rounded,
      title: 'Kembangkan Bisnis',
      description:
          'Siap membawa usaha Anda ke level berikutnya? Mari kita mulai sekarang!',
    ),
  ];

  void forwardAction() {
    if (isLastPage) {
      // Navigasi ke LoginView dan hapus history onboarding
      Get.off(() => const LoginView());
    } else {
      pageController.nextPage(duration: 300.milliseconds, curve: Curves.ease);
    }
  }
}

// Model sederhana untuk data onboarding
class OnboardingInfo {
  final IconData imageAsset;
  final String title;
  final String description;

  OnboardingInfo({
    required this.imageAsset,
    required this.title,
    required this.description,
  });
}
