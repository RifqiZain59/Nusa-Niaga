import 'package:get/get.dart';
import 'package:nusaniaga/app/modules/onboarding/views/onboarding_view.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    // Memulai timer saat halaman selesai ditampilkan
    _startTimer();
  }

  void _startTimer() async {
    // Tunggu 5 detik
    await Future.delayed(const Duration(seconds: 5));

    // Pindah ke OnboardingView
    // Menggunakan Get.off() agar tidak bisa kembali (Back) ke Splash Screen
    Get.off(
      () => const OnboardingView(),
      transition: Transition.fadeIn, // Efek transisi halus
      duration: const Duration(milliseconds: 800),
    );
  }
}
