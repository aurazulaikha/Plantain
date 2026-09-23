import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<dynamic> topUsers = [];
  bool isLoading = true;

  String? token;

  @override
  void initState() {
    super.initState();
    loadTokenAndFetch();
  }

  // AMBIL TOKEN DARI SHARED PREF 
  Future<void> loadTokenAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    if (token == null) {
      setState(() {
        isLoading = false;
      });
      print("TOKEN NULL - USER BELUM LOGIN");
      return;
    }

    fetchTopUsers();
  }

  Future<void> fetchTopUsers() async {
    try {
      final res = await http.get(
        Uri.parse("http://103.247.9.235:5000/admin/statistik"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("STATUS CODE: ${res.statusCode}");
      print("RESPONSE BODY: ${res.body}");

      if (!mounted) return;

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);

        setState(() {
          topUsers = decoded is List ? decoded : [];
          isLoading = false;
        });
      } else {
        setState(() {
          topUsers = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print("ERROR FETCH USER AKTIF: $e");
      setState(() {
        topUsers = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryGreen = const Color(0xFF43A047);
    final darkGreen = const Color(0xFF1B5E20);
    final lightGreen = const Color(0xFFC8E6C9);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
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
                    color: Colors.black.withOpacity(0.15),
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
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
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
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings,
                        color: primaryGreen, size: 30),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Selamat datang Admin. Kelola, pantau aktivitas pengguna, dan statistik sistem di sini.",
                        style: TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22),
              child: Text(
                "User Teraktif",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : topUsers.isEmpty
                      ? const Center(
                          child: Text(
                            "Belum ada data user aktif",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : Column(
                          children: List.generate(topUsers.length, (index) {
                            final user = topUsers[index];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        primaryGreen.withOpacity(0.15),
                                    child: Text(
                                      "${index + 1}",
                                      style: TextStyle(
                                        color: primaryGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user['nama']?.toString() ?? '-',
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Total deteksi: ${user['total_deteksi'] ?? 0}",
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.trending_up,
                                      color: primaryGreen),
                                ],
                              ),
                            );
                          }),
                        ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}