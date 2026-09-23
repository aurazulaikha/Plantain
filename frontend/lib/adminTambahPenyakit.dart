import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminTambahPenyakit extends StatefulWidget {
  const AdminTambahPenyakit({super.key});

  @override
  State<AdminTambahPenyakit> createState() =>
      _AdminTambahPenyakitState();
}

class _AdminTambahPenyakitState
    extends State<AdminTambahPenyakit> {
  final TextEditingController namaC =
      TextEditingController();

  final TextEditingController deskripsiC =
      TextEditingController();

  final TextEditingController gejalaC =
      TextEditingController();

  final TextEditingController pencegahanC =
      TextEditingController();

  final TextEditingController mengatasiC =
      TextEditingController();

  final TextEditingController bahayaC =
      TextEditingController();

  bool loading = false;

  File? pickedImage;

  final String baseUrl = "http://103.247.9.235:5000";

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        pickedImage = File(picked.path);
      });
    }
  }

  void showMsg(
    String msg, {
    VoidCallback? onOk,
  }) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Informasi"),
            content: Text(msg),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  if (onOk != null) {
                    onOk();
                  }
                },
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  Future<void> submit() async {
    if (namaC.text.trim().isEmpty) {
      showMsg("Nama penyakit wajib diisi");
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      String? token = await getToken();

      var request = http.MultipartRequest(
        "POST",
        Uri.parse(
          "$baseUrl/admin/penyakit",
        ),
      );

      request.headers["Authorization"] =
          "Bearer $token";

      request.fields["nama"] =
          namaC.text.trim();

      request.fields["deskripsi"] =
          deskripsiC.text.trim();

      request.fields["gejala"] =
          gejalaC.text.trim();

      request.fields["pencegahan"] =
          pencegahanC.text.trim();

      request.fields["mengatasi"] =
          mengatasiC.text.trim();

      request.fields["bahaya"] =
          bahayaC.text.trim();

      if (pickedImage != null) {
        final ext =
            pickedImage!.path.split(".").last;

        request.files.add(
          await http.MultipartFile.fromPath(
            "gambar",
            pickedImage!.path,
            contentType: MediaType(
              "image",
              ext,
            ),
          ),
        );
      }

      final response =
          await request.send();

      final resBody =
          await http.Response.fromStream(
            response,
          );

      final data =
          jsonDecode(resBody.body);

      if (!mounted) return;

      if (response.statusCode == 201) {
        showMsg(
          "Penyakit berhasil ditambahkan",
          onOk: () {
            Navigator.pop(
              context,
              true,
            );
          },
        );
      } else {
        showMsg(
          data["message"] ??
              "Gagal menambahkan penyakit",
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }

      showMsg("Error : $e");
    }

    setState(() {
      loading = false;
    });
  }

  Widget buildInput(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border:
              const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen =
        Color(0xFF1B5E20);

    const lightGreen =
        Color(0xFFC8E6C9);

    const primaryGreen =
        Color(0xFF43A047);

    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.fromLTRB(
                    20,
                    50,
                    20,
                    20,
                  ),
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius:
                    const BorderRadius.only(
                      bottomLeft:
                          Radius.circular(35),
                      bottomRight:
                          Radius.circular(35),
                    ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(
                      0,
                      3,
                    ),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed:
                        () =>
                            Navigator.pop(
                              context,
                            ),
                    icon: Icon(
                      Icons.arrow_back,
                      color: darkGreen,
                    ),
                  ),

                  const Text(
                    "Tambah Penyakit",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight:
                          FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                    horizontal: 22,
                  ),
              child: Column(
                children: [
                  buildInput(
                    "Nama Penyakit",
                    namaC,
                  ),

                  buildInput(
                    "Deskripsi",
                    deskripsiC,
                    maxLines: 4,
                  ),

                  buildInput(
                    "Gejala",
                    gejalaC,
                    maxLines: 5,
                  ),

                  buildInput(
                    "Pencegahan",
                    pencegahanC,
                    maxLines: 5,
                  ),

                  buildInput(
                    "Cara Pengendalian",
                    mengatasiC,
                    maxLines: 5,
                  ),

                  buildInput(
                    "Bahaya",
                    bahayaC,
                    maxLines: 4,
                  ),

                  const SizedBox(height: 10),

                  InkWell(
                    onTap: pickImage,
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(
                            14,
                          ),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(
                              14,
                            ),
                        border: Border.all(
                          color: primaryGreen,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.image,
                            color:
                                primaryGreen,
                            size: 35,
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            pickedImage == null
                                ? "Pilih Gambar Penyakit"
                                : "Gambar berhasil dipilih ✔",
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (pickedImage != null)
                    Container(
                      margin:
                          const EdgeInsets.only(
                            top: 15,
                          ),
                      height: 180,
                      width:
                          double.infinity,
                      decoration:
                          BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(
                                  15,
                                ),
                            image:
                                DecorationImage(
                                  image: FileImage(
                                    pickedImage!,
                                  ),
                                  fit:
                                      BoxFit.cover,
                                ),
                          ),
                    ),

                  const SizedBox(
                    height: 25,
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(
                            backgroundColor:
                                primaryGreen,
                            shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                        14,
                                      ),
                                ),
                          ),
                      onPressed:
                          loading
                              ? null
                              : submit,
                      child:
                          loading
                              ? const CircularProgressIndicator(
                                color:
                                    Colors
                                        .white,
                              )
                              : const Text(
                                "Simpan Penyakit",
                                style: TextStyle(
                                  color:
                                      Colors
                                          .white,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}