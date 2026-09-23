import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'editProfile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  final String baseUrl = "http://103.247.9.235:5000";
  String token = "";

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  void loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token") ?? "";

    if (token.isNotEmpty) {
      fetchProfile();
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchProfile() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/profile"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() {
          profileData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (kDebugMode) print("ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  // LOGOUT FUNCTION
  Future<void> logoutUser() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/logout"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (kDebugMode) {
        print("LOGOUT STATUS: ${response.statusCode}");
        print("LOGOUT BODY: ${response.body}");
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove("token");

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      }
    } catch (e) {
      if (kDebugMode) print("LOGOUT ERROR: $e");
    }
  }

  // KONFIRMASI LOGOUT
  Future<void> confirmLogout() async {
    bool? result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Konfirmasi Logout"),
            content: const Text("Apakah Anda yakin ingin keluar dari akun?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Tidak"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Ya", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (result == true) {
      logoutUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkGreen = const Color(0xFF1B5E20);
    final lightGreen = const Color(0xFFC8E6C9);
    final primaryGreen = const Color(0xFF43A047);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 35),
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
                padding: const EdgeInsets.only(top: 5, left: 10),
                child: Text(
                  "Profil",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLoading)
                    const Center(child: CircularProgressIndicator()),

                  if (!isLoading && profileData != null) ...[
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            (profileData!['foto_url'] != null)
                                ? NetworkImage(profileData!['foto_url'])
                                : null,
                        backgroundColor: Colors.grey.shade300,
                        child:
                            (profileData!['foto_url'] == null)
                                ? const Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Colors.white,
                                )
                                : null,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Center(
                      child: Text(
                        profileData!['nama'] ?? "-",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.05),
                        border: Border.all(
                          color: primaryGreen.withOpacity(0.25),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _rowItem("Email", profileData!['email']),
                          _divider(),
                          _rowItem("No. Telepon", profileData!['no_telepon']),
                          _divider(),
                          _rowItem("Alamat", profileData!['alamat']),
                          _divider(),
                          _rowItem("Username", profileData!['username']),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              bool? updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditProfilePage(),
                                ),
                              );

                              if (updated == true) {
                                fetchProfile();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Edit Profil",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        SizedBox(
                          width: 150,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: confirmLogout, // ✅ pakai konfirmasi
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                195,
                                45,
                                34,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Logout",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowItem(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(fontSize: 15),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      height: 1,
      width: double.infinity,
      color: Colors.grey.withOpacity(0.25),
    );
  }
}
