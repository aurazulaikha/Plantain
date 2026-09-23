import 'package:flutter/material.dart';
import 'package:plantain/adminKelolaPenyakit.dart';
import 'package:plantain/profile.dart';
import 'adminDashboard.dart';
import 'adminUser.dart';

class AdminNavigation extends StatefulWidget {
  const AdminNavigation({super.key});

  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    AdminDashboardPage(),
    AdminUserPage(),
    AdminKelolaPenyakitPage(),
    ProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    final darkGreen = const Color(0xFF1B5E20);
    final lightGreen = const Color(0xFFC8E6C9);

    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: Container(
        height: 65,
        decoration: BoxDecoration(
          color: lightGreen,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(
              icon: Icons.dashboard,
              label: "Dashboard",
              active: currentIndex == 0,
              activeColor: darkGreen,
              onTap: () => setState(() => currentIndex = 0),
            ),

            _navItem(
              icon: Icons.people,
              label: "User",
              active: currentIndex == 1,
              activeColor: darkGreen,
              onTap: () => setState(() => currentIndex = 1),
            ),

            _navItem(
              icon: Icons.local_florist,
              label: "Penyakit",
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