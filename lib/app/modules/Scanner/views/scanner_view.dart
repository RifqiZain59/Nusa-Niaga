import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  // [FIX 1] Definisikan controller agar bisa dikontrol (senter/kamera)
  final MobileScannerController scannerController = MobileScannerController();

  @override
  void dispose() {
    // [FIX 2] Hapus controller dari memori saat halaman ditutup
    scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Menggunakan extendBodyBehindAppBar agar kamera memenuhi layar sampai ke atas
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Scan QR Code"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Ionicons.flash_outline),
            // [FIX 3] Gunakan controller yang sudah didefinisikan di atas
            onPressed: () => scannerController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Ionicons.camera_reverse_outline),
            onPressed: () => scannerController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Widget Utama Kamera
          MobileScanner(
            controller: scannerController, // Hubungkan ke controller
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  // Kirim hasil scan kembali ke PoinController
                  Get.back(result: barcode.rawValue);
                  break;
                }
              }
            },
          ),

          // Custom Overlay Kotak Fokus
          _buildOverlay(context),
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Container(
      // Membuat efek gelap di luar kotak fokus
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: Colors.white,
          borderRadius: 12,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 250, // Ukuran lubang scan
        ),
      ),
      child: const Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: 100),
          child: Text(
            "Arahkan ke QR Code",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

// Widget pembantu untuk membuat lubang transparan di tengah (Overlay)
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderLength;
  final double borderRadius;
  final double cutOutSize;

  QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 4.0,
    this.borderLength = 20.0,
    this.borderRadius = 0,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRect(rect);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final center = rect.center;
    final cutOutRect = Rect.fromCenter(
      center: center,
      width: cutOutSize,
      height: cutOutSize,
    );

    final backgroundPaint = Paint()
      ..color = Colors.black54; // Warna gelap transparan
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Gambar background gelap dengan lubang di tengah
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()..addRRect(
          RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
        ),
      ),
      backgroundPaint,
    );

    // Gambar Border kotak putih
    canvas.drawRRect(
      RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) => this;
}
