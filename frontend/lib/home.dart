import 'package:flutter/material.dart';
import 'deteksi_realtime.dart';
import 'uploadGambar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int selectedButton = -1;

  // Controller animasi tombol
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF43A047);
    final Color darkGreen = const Color(0xFF1B5E20);
    final Color lightGreen = const Color(0xFFC8E6C9);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.15 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 5, left: 20),
                child: Text(
                  "Plantain",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22),
              child: Text(
                "Halo, selamat datang di Plantain! aplikasi yang mampu mendeteksi jenis penyakit daun "
                "pada tanaman pisang kamu loh!\n\n"
                "Tunggu apa lagi? ayo deteksi jenis penyakit daun pisang kamu sebelum mengalami kerugian!",
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
            ),

            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _menuButton(
                      index: 0,
                      text: "Upload Gambar",
                      primaryGreen: primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _menuButton(
                      index: 1,
                      text: "Deteksi Realtime",
                      primaryGreen: primaryGreen,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.1 * 255).round()),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: primaryGreen, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Tips Hari Ini: Pastikan tanaman pisang mendapatkan sinar matahari cukup dan jarak tanam teratur.",
                        style: TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),
            Center(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset(
                      "assets/images/onboard2.jpg",
                      width: 240,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    width: 240,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withAlpha((0.2 * 255).round()),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "🌱 Tetap rawat tanamanmu, panen pun senang!",
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton({
    required int index,
    required String text,
    required Color primaryGreen,
  }) {
    final bool active = selectedButton == index;

    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) => _controller.forward(),
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                active
                    ? primaryGreen
                    : primaryGreen.withAlpha((0.12 * 255).round()),
            foregroundColor: active ? Colors.white : primaryGreen,
            elevation: active ? 4 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          onPressed: () {
            setState(() => selectedButton = index);

            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UploadDetectionPage(),
                ),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RealtimeDetectionPage(),
                ),
              );
            }
          },
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
