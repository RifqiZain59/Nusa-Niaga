import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk SystemChrome & Clipboard
import 'package:get/get.dart';
import 'package:nusaniaga/app/modules/detail_promo/controllers/detail_promo_controller.dart';

class DetailPromoView extends GetView<DetailPromoController> {
  const DetailPromoView({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengatur System UI Overlay Style (Status dan Navigation Bar)
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Background abu-abu muda
      appBar: AppBar(
        backgroundColor:
            Colors.grey.shade100, // Sesuaikan dengan background body
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          // *** PERUBAHAN UTAMA DI SINI: AKTIFKAN FUNGSI KEMBALI ***
          onPressed: () {
            Get.back(); // Perintah untuk kembali ke halaman sebelumnya
          },
          // *** AKHIR PERUBAHAN ***
        ),
        title: const Text(
          'Detail Promo',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildPromoCard(),
            const SizedBox(height: 20),
            _buildHowToGetPromo(),
          ],
        ),
      ),
    );
  }

  // Widget untuk Kartu Promo
  Widget _buildPromoCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Tag "Promo"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.discount, color: Colors.orange.shade800, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Promo',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '10% off Best Sunday',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Exclusive deal! Enjoy 10% off this Sunday only. Don\'t miss your chance to save on your favorites!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Coupon Design (Kotak Melengkung Sederhana)
          _buildCouponDesign(),
          const SizedBox(height: 20),

          // Ketersediaan & Kode
          Text(
            'Available: Dine-in only, this Sunday',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          _buildPromoCodeSection(),
        ],
      ),
    );
  }

  // Widget untuk Desain Kupon (Rounded Rectangle)
  Widget _buildCouponDesign() {
    const Color couponColor = Color(0xFF4CAF50);

    return Center(
      child: Container(
        height: 70,
        width: 200,
        decoration: BoxDecoration(
          color: couponColor,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '10% Off',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Best Sunday',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk Kode Promo yang bisa disalin
  Widget _buildPromoCodeSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Code: ',
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'SUNDAY10',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: 'SUNDAY10'));
                  Get.snackbar(
                    'Berhasil Disalin',
                    'Kode promo SUNDAY10 telah disalin!',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.shade600,
                    colorText: Colors.white,
                  );
                },
                child: const Icon(Icons.copy, color: Colors.blue, size: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget untuk Bagian Cara Mendapatkan Promo
  Widget _buildHowToGetPromo() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            'How to Get the Promo:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildStep(
            'Visit Our Bakery Café',
            'Join us for a cozy dine-in experience this Sunday.',
          ),
          _buildStep(
            'Choose Your Favorites',
            'Select from our freshly baked pastries, breads, and drinks.',
          ),
          _buildStep(
            'Enjoy Your Discount',
            'Relax and enjoy your meal with 10% off.',
          ),
          _buildStep(
            'Claim 10% Off',
            'Mention SUNDAY10 to your server when ordering.',
          ),
        ],
      ),
    );
  }

  // Widget pembantu untuk langkah-langkah
  Widget _buildStep(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Icon(Icons.circle, size: 8, color: Colors.blue),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
