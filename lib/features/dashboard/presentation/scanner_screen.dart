import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../logic/dashboard_cubit.dart';
import '../../auth/logic/profile_cubit.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isScanning = true;

  void _onDetect(BarcodeCapture capture) async {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      setState(() => _isScanning = false);
      final String code = barcodes.first.rawValue!;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator(color: Color(0xFF3E2723))),
      );

      try {
        await context.read<DashboardCubit>().processEarnQr(code);

        if (mounted) Navigator.pop(context);

        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 60),
                  SizedBox(height: 16),
                  Text('Hore!', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: const Text(
                'Poin kamu berhasil ditambahkan dari pesanan ini!',
                textAlign: TextAlign.center,
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E2723),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Tutup', style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          );

          context.read<ProfileCubit>().fetchProfile();
          context.read<DashboardCubit>().loadDashboardData();
          context.pop();
        }
      } catch (e) {
        if (mounted) Navigator.pop(context);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
          setState(() => _isScanning = true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double scanWindowSize = 250.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan untuk Dapat Poin', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _onDetect,
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates,
            ),
          ),

          // Solusi Anti-Putih: Menggunakan mask posisi hitam transparan di sekeliling kotak
          CustomPaint(
            painter: ScannerOverlayPainter(scanWindowSize: scanWindowSize),
            child: const SizedBox.expand(),
          ),

          // Teks Instruksi di Bawah Kotak Scanner
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 80),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Arahkan kamera ke QR Code dari Barista',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Painter untuk membuat area luar kotak scan menjadi gelap transparan
// Helper Painter untuk membuat area luar kotak scan menjadi gelap transparan
class ScannerOverlayPainter extends CustomPainter {
  final double scanWindowSize;

  ScannerOverlayPainter({required this.scanWindowSize});

  @override
  void paint(Canvas canvas, Size size) {
    // Menggunakan withAlpha(153) sebagai pengganti withOpacity(0.6) untuk menghindari warning
    final paint = Paint()..color = Colors.black.withAlpha(153);

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanWindowSize,
      height: scanWindowSize,
    );

    canvas.saveLayer(rect, paint);
    canvas.drawRect(rect, paint);

    // Lubangi bagian tengah (area kotak scan)
    final cutoutPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(16)),
      cutoutPaint,
    );
    canvas.restore();

    // Gambar border putih di sekeliling kotak
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(16)),
      borderPaint,
    );
  }

  // INI ADALAH METHOD YANG HILANG (Wajib ada di CustomPainter)
  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanWindowSize != scanWindowSize;
  }
}