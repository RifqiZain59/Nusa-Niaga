import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../home/views/home_view.dart';
import '../../onboarding/views/onboarding_view.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    // 1. Tunggu durasi splash screen (misal 3-5 detik agar logo terlihat)
    await Future.delayed(const Duration(seconds: 4));

    // 2. Cek SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    bool isLogin = prefs.getBool('is_login') ?? false;

    // 3. Navigasi berdasarkan status login
    if (isLogin) {
      Get.offAll(
        () => const HomeView(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 800),
      );
    } else {
      Get.off(
        () => const OnboardingView(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 800),
      );
    }
  }
}
