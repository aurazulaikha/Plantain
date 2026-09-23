import 'package:flutter/material.dart';
import 'home.dart';
import 'edukasi.dart';
import 'riwayat.dart';
import 'profile.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomePage(),
    EdukasiPage(),
    RiwayatPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    const primaryGreen = Color(0xFF43A047);
    const darkGreen = Color(0xFF1B5E20);
    const lightGreen = Color(0xFFC8E6C9);

    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: Container(
        height: 65,
        decoration: BoxDecoration(
          color: lightGreen,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(
              icon: Icons.home_filled,
              label: "Home",
              active: currentIndex == 0,
              activeColor: darkGreen,
              onTap: () => setState(() => currentIndex = 0),
            ),
            _navItem(
              icon: Icons.book_outlined,
              label: "Edukasi",
              active: currentIndex == 1,
              activeColor: darkGreen,
              onTap: () => setState(() => currentIndex = 1),
            ),
            _navItem(
              icon: Icons.history,
              label: "Riwayat",
              active: currentIndex == 2,
              activeColor: darkGreen,
              onTap: () => setState(() => currentIndex = 2),
            ),
            _navItem(
              icon: Icons.person_outline,
              label: "Profil",
              active: currentIndex == 3,
              activeColor: darkGreen,
              onTap: () => setState(() => currentIndex = 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool active,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    const primaryGreen = Color(0xFF43A047);

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          active
              ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              )
              : Icon(icon, color: primaryGreen, size: 22),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: active ? activeColor : primaryGreen,
              fontSize: 11,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
