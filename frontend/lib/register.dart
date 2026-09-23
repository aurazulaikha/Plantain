import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailC = TextEditingController();
  final TextEditingController namaC = TextEditingController();
  final TextEditingController telpC = TextEditingController();
  final TextEditingController alamatC = TextEditingController();
  final TextEditingController usernameC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  final TextEditingController confirmPasswordC = TextEditingController();

  bool loading = false;
  File? selectedImage;
  bool showPassword = false;
  bool showConfirmPassword = false;

  final ImagePicker _picker = ImagePicker();

  // VALIDASI EMAIL
  bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  Future<void> pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  // REGISTER
  Future<void> registerUser() async {
    if (emailC.text.isEmpty ||
        namaC.text.isEmpty ||
        telpC.text.isEmpty ||
        alamatC.text.isEmpty ||
        usernameC.text.isEmpty ||
        passwordC.text.isEmpty ||
        confirmPasswordC.text.isEmpty) {
      _showDialog("Semua field wajib diisi");
      return;
    }

    // Validasi email
    if (!isValidEmail(emailC.text)) {
      _showDialog("Format email tidak valid. Contoh: email@gmail.com");
      return;
    }

    // Validasi password dan konfirmasi password
    if (passwordC.text != confirmPasswordC.text) {
      _showDialog("Password dan konfirmasi password tidak sama");
      return;
    }

    setState(() => loading = true);

    try {
      final url = Uri.parse("http://103.247.9.235:5000/register");

      var request = http.MultipartRequest("POST", url);

      request.fields['nama'] = namaC.text;
      request.fields['email'] = emailC.text;
      request.fields['no_telepon'] = telpC.text;
      request.fields['alamat'] = alamatC.text;
      request.fields['username'] = usernameC.text;
      request.fields['password'] = passwordC.text;

      if (selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath("foto", selectedImage!.path),
        );
      }

      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      final data = jsonDecode(resBody);

      if (response.statusCode == 201) {
        _showDialogWithAction("Registrasi berhasil!", () {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, "/login");
        });
      } else {
        _showDialog(data["message"] ?? "Gagal daftar");
      }
    } catch (e) {
      _showDialog("Error koneksi: $e");
    }

    setState(() => loading = false);
  }

  // POP UP
  void _showDialog(String msg) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Informasi"),
            content: Text(msg),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  void _showDialogWithAction(String msg, VoidCallback onOk) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Informasi"),
            content: Text(msg),
            actions: [TextButton(onPressed: onOk, child: const Text("OK"))],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              // LOGO
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/images/logo.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              _inputField("Email", emailC, green),
              const SizedBox(height: 15),

              _inputField("Nama", namaC, green),
              const SizedBox(height: 15),

              _inputField("No Telepon", telpC, green),
              const SizedBox(height: 15),

              _inputField("Alamat", alamatC, green),
              const SizedBox(height: 15),

              _inputField("Username", usernameC, green),
              const SizedBox(height: 15),

              // PASSWORD
              TextField(
                controller: passwordC,
                obscureText: !showPassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: green, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => showPassword = !showPassword);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // KONFIRMASI PASSWORD
              TextField(
                controller: confirmPasswordC,
                obscureText: !showConfirmPassword,
                decoration: InputDecoration(
                  labelText: "Konfirmasi Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: green, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(
                        () => showConfirmPassword = !showConfirmPassword,
                      );
                    },
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
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: green),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, color: green),
                      const SizedBox(width: 8),
                      Text(
                        selectedImage == null
                            ? "Pilih Foto (Opsional)"
                            : "Foto dipilih",
                        style: TextStyle(color: green),
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
                    backgroundColor: green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: loading ? null : registerUser,
                  child:
                      loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "Daftar",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sudah punya akun? "),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, "/login");
                    },
                    child: Text(
                      "Masuk",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController c, Color greenColor) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: greenColor, width: 2),
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }
}
