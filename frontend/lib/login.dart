import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  bool loading = false;
  bool showPassword = false; // toggle visibility password

  Future<void> loginUser() async {
    if (usernameC.text.isEmpty || passwordC.text.isEmpty) {
      _showDialog("Isi username dan password");
      return;
    }

    setState(() => loading = true);

    try {
      final url = Uri.parse("http://103.247.9.235:5000/login");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": usernameC.text,
          "password": passwordC.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);
        await prefs.setInt("user_id", data["user_id"]);
        await prefs.setString("role", data["role"]);

        if (data["role"] == "admin") {
          Navigator.pushReplacementNamed(context, "/admin");
        } else {
          Navigator.pushReplacementNamed(context, "/home");
        }
      } else {
        // pesan gagal login
        _showDialog("Username atau password salah");
      }
    } catch (e) {
      _showDialog("Error koneksi: $e");
    }

    setState(() => loading = false);
  }

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
                width: 120,
                height: 120,
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

              const SizedBox(height: 40),

              // USERNAME
              TextField(
                controller: usernameC,
                decoration: InputDecoration(
                  labelText: "Username",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: green, width: 2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // PASSWORD
              TextField(
                controller: passwordC,
                obscureText: !showPassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: green, width: 2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
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

              const SizedBox(height: 30),

              // TOMBOL LOGIN
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
                  onPressed: loading ? null : loginUser,
                  child:
                      loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "Masuk",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 20),

              // REGISTER
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum punya akun? "),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, "/register");
                    },
                    child: Text(
                      "Daftar",
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
}
