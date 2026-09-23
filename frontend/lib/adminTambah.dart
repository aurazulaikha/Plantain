import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminTambah extends StatefulWidget {
  const AdminTambah({super.key});

  @override
  State<AdminTambah> createState() => _AdminTambahState();
}

class _AdminTambahState extends State<AdminTambah> {
  final TextEditingController emailC = TextEditingController();
  final TextEditingController namaC = TextEditingController();
  final TextEditingController telpC = TextEditingController();
  final TextEditingController alamatC = TextEditingController();
  final TextEditingController usernameC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  final TextEditingController confirmPasswordC = TextEditingController();

  bool loading = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  File? pickedImage;

  final String baseUrl = "http://103.247.9.235:5000";

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => pickedImage = File(picked.path));
    }
  }

  void showMsg(String msg, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Informasi"),
            content: Text(msg),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                  if (onOk != null) onOk();
                },
              ),
            ],
          ),
    );
  }

  Future<void> submit() async {
    if (namaC.text.isEmpty ||
        emailC.text.isEmpty ||
        usernameC.text.isEmpty ||
        passwordC.text.isEmpty) {
      showMsg("Nama, email, username, password wajib diisi");
      return;
    }

    if (passwordC.text != confirmPasswordC.text) {
      showMsg("Password dan konfirmasi tidak sama");
      return;
    }

    setState(() => loading = true);

    try {
      String? token = await getToken();

      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/admin/tambah"),
      );

      request.headers['Authorization'] = "Bearer $token";

      request.fields['nama'] = namaC.text;
      request.fields['email'] = emailC.text;
      request.fields['no_telepon'] = telpC.text;
      request.fields['alamat'] = alamatC.text;
      request.fields['username'] = usernameC.text;
      request.fields['password'] = passwordC.text;

      request.fields['role'] = "admin";

      if (pickedImage != null) {
        final ext = pickedImage!.path.split('.').last;

        request.files.add(
          await http.MultipartFile.fromPath(
            "foto",
            pickedImage!.path,
            contentType: MediaType("image", ext),
          ),
        );
      }

      final response = await request.send();
      final resBody = await http.Response.fromStream(response);
      final data = jsonDecode(resBody.body);

      if (!mounted) return;

      if (response.statusCode == 201) {
        showMsg(
          "Admin berhasil ditambahkan",
          onOk: () {
            Navigator.pop(context, true);
          },
        );
      } else {
        showMsg(data["message"] ?? "Gagal menambah admin");
      }
    } catch (e) {
      if (kDebugMode) print(e);
      showMsg("Error: $e");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final darkGreen = const Color(0xFF1B5E20);
    final lightGreen = const Color(0xFFC8E6C9);
    final primaryGreen = const Color(0xFF43A047);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
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
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: darkGreen),
                  ),
                  Text(
                    "Tambah Admin",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  _input("Nama", namaC),
                  _input("Email", emailC),
                  _input("No Telepon", telpC),
                  _input("Alamat", alamatC),
                  _input("Username", usernameC),

                  const SizedBox(height: 15),

                  TextField(
                    controller: passwordC,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed:
                            () => setState(() => showPassword = !showPassword),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: confirmPasswordC,
                    obscureText: !showConfirmPassword,
                    decoration: InputDecoration(
                      labelText: "Konfirmasi Password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed:
                            () => setState(
                              () => showConfirmPassword = !showConfirmPassword,
                            ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  InkWell(
                    onTap: pickImage,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: primaryGreen),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, color: primaryGreen),
                          const SizedBox(width: 8),
                          Text(
                            pickedImage == null
                                ? "Pilih Foto (Opsional)"
                                : "Foto sudah dipilih ✔",
                            style: TextStyle(color: primaryGreen),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: loading ? null : submit,
                      child:
                          loading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                "Simpan",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: c,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ).copyWith(labelText: label),
      ),
    );
  }
}
