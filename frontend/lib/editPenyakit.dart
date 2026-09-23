import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditPenyakitPage extends StatefulWidget {
  final Map penyakit;

  const EditPenyakitPage({super.key, required this.penyakit});

  @override
  State<EditPenyakitPage> createState() => _EditPenyakitPageState();
}

class _EditPenyakitPageState extends State<EditPenyakitPage> {
  late TextEditingController namaC;
  late TextEditingController deskripsiC;
  late TextEditingController gejalaC;
  late TextEditingController pencegahanC;
  late TextEditingController mengatasiC;
  late TextEditingController bahayaC;

  File? pickedImage;

  bool loading = false;

  final String baseUrl = "http://103.247.9.235:5000";

  @override
  void initState() {
    super.initState();

    namaC = TextEditingController(text: widget.penyakit['nama'] ?? "");
    deskripsiC = TextEditingController(
      text: widget.penyakit['deskripsi'] ?? "",
    );
    gejalaC = TextEditingController(text: widget.penyakit['gejala'] ?? "");
    pencegahanC = TextEditingController(
      text: widget.penyakit['pencegahan'] ?? "",
    );
    mengatasiC = TextEditingController(
      text: widget.penyakit['mengatasi'] ?? "",
    );

    bahayaC = TextEditingController(text: widget.penyakit['bahaya'] ?? "");
  }

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

  void showMsg(String msg, {VoidCallback? onOk}) {
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

  Future<void> updatePenyakit() async {
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
        "PUT",
        Uri.parse("$baseUrl/admin/penyakit/${widget.penyakit['id']}"),
      );

      request.headers["Authorization"] = "Bearer $token";

      request.fields["nama"] = namaC.text.trim();
      request.fields["deskripsi"] = deskripsiC.text.trim();
      request.fields["gejala"] = gejalaC.text.trim();
      request.fields["pencegahan"] = pencegahanC.text.trim();
      request.fields["mengatasi"] = mengatasiC.text.trim();
      request.fields["bahaya"] = bahayaC.text.trim();

      if (pickedImage != null) {
        final ext = pickedImage!.path.split('.').last;

        request.files.add(
          await http.MultipartFile.fromPath(
            "gambar",
            pickedImage!.path,
            contentType: MediaType("image", ext),
          ),
        );
      }

      final response = await request.send();

      final resBody = await http.Response.fromStream(response);

      final data = jsonDecode(resBody.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        showMsg(
          "Penyakit berhasil diperbarui",
          onOk: () {
            Navigator.pop(context, true);
          },
        );
      } else {
        showMsg(data["message"] ?? "Gagal memperbarui penyakit");
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
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF1B5E20);
    const lightGreen = Color(0xFFC8E6C9);
    const primaryGreen = Color(0xFF43A047);

    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
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
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: darkGreen),
                  ),

                  Text(
                    "Edit Penyakit",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // FOTO PENYAKIT
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child:
                    pickedImage != null
                        ? Image.file(
                          pickedImage!,
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                        )
                        : widget.penyakit['gambar_url'] != null
                        ? Image.network(
                          widget.penyakit['gambar_url'],
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                        )
                        : Container(
                          width: 180,
                          height: 180,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 70),
                        ),
              ),
            ),

            const SizedBox(height: 15),

            Center(
              child: Text(
                namaC.text,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.05),
                  border: Border.all(color: primaryGreen.withOpacity(0.25)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    buildInput("Nama Penyakit", namaC),
                    buildInput("Deskripsi", deskripsiC, maxLines: 4),
                    buildInput("Gejala", gejalaC, maxLines: 5),
                    buildInput("Pencegahan", pencegahanC, maxLines: 5),
                    buildInput("Cara Pengendalian", mengatasiC, maxLines: 5),
                    buildInput("Bahaya", bahayaC, maxLines: 4),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryGreen),
                  ),
                  onPressed: pickImage,
                  icon: Icon(Icons.image, color: primaryGreen),
                  label: Text(
                    "Ganti Gambar",
                    style: TextStyle(color: primaryGreen),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: loading ? null : updatePenyakit,
                  child:
                      loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "Update Penyakit",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
