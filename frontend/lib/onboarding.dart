import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> pages = [
    {
      "image": "assets/images/onboard1.jpg",
      "title": "Plantain",
      "desc": "Deteksi penyakit daun pada tanaman pisang anda!",
    },
    {
      "image": "assets/images/onboard2.jpg",
      "title": "Plantain",
      "desc":
          "Ayo dapatkan informasi tentang pencegahan penyakit daun pada tanaman pisang!",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: (index) {
                setState(() => currentIndex = index);
              },
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 220,
                      width: 350,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          pages[index]["image"]!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // judul
                    Text(
                      pages[index]["title"]!,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: green,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        pages[index]["desc"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          SmoothPageIndicator(
            controller: _controller,
            count: pages.length,
            effect: ExpandingDotsEffect(
              activeDotColor: green,
              dotColor: Colors.grey.shade400,
              dotHeight: 10,
              dotWidth: 10,
            ),
          ),

          const SizedBox(height: 20),
          _buildButtons(context),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;

    if (currentIndex == 0) {
      return ElevatedButton(
        onPressed:
            () => _controller.nextPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text("Selanjutnya"),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed:
              () => _controller.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: green, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text("Kembali"),
          ),
        ),

        const SizedBox(width: 20),

        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, "/login");
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
            child: Text("Masuk"),
          ),
        ),
      ],
    );
  }
}
