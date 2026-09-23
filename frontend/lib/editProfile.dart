import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  String token = "";
  final String baseUrl = "http://103.247.9.235:5000";

  File? pickedImage;

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  void loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token") ?? "";
    if (token.isNotEmpty) fetchProfile();
  }

  Future<void> fetchProfile() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/profile"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final profileData = jsonDecode(response.body);
        nameController.text = profileData['nama'] ?? "";
        emailController.text = profileData['email'] ?? "";
        phoneController.text = profileData['no_telepon'] ?? "";
        addressController.text = profileData['alamat'] ?? "";
        usernameController.text = profileData['username'] ?? "";
      }
    } catch (e) {
      if (kDebugMode) print("ERROR: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => pickedImage = File(picked.path));
    }
  }

  Future<void> updateProfile() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama, username, dan email wajib diisi")),
      );
      return;
    }

    if (passwordController.text.isNotEmpty &&
        passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password dan konfirmasi password tidak sama"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      var uri = Uri.parse("$baseUrl/profile/edit");
      var request =
          http.MultipartRequest('PUT', uri)
            ..headers['Authorization'] = "Bearer $token"
            ..fields['nama'] = nameController.text
            ..fields['email'] = emailController.text
            ..fields['username'] = usernameController.text
            ..fields['no_telepon'] = phoneController.text
            ..fields['alamat'] = addressController.text;

      if (passwordController.text.isNotEmpty) {
        request.fields['password'] = passwordController.text;
      }

      if (pickedImage != null) {
        final ext = pickedImage!.path.split('.').last.toLowerCase();
        final length = await pickedImage!.length();
        request.files.add(
          http.MultipartFile(
            'foto',
            pickedImage!.openRead(),
            length,
            filename: "user_photo.$ext",
            contentType: MediaType("image", ext),
          ),
        );
      }

      var response = await request.send();
      var resBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
        // ignore: use_build_context_synchronously
        Navigator.pop(context, true);
      } else {
        final msg =
            jsonDecode(resBody.body)['message'] ?? "Failed to update profile";
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (kDebugMode) print("ERROR: $e");
    }

    setState(() => isLoading = false);
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: darkGreen, size: 28),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      "Edit Profil",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  if (isLoading)
                    const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'No. Telepon',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Alamat',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  // Password
                  TextField(
                    controller: passwordController,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: 'Password (opsional)',
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
                  const SizedBox(height: 20),
                  // Konfirmasi Password
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: !showConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password',
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
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: pickImage,
                        child: const Text("Pilih Foto"),
                      ),
                      const SizedBox(width: 10),
                      if (pickedImage != null)
                        Text(pickedImage!.path.split('/').last),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Simpan Perubahan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
