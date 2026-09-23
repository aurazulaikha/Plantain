import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'adminTambahPenyakit.dart';
import 'editPenyakit.dart';
import 'package:flutter_html/flutter_html.dart';

class AdminKelolaPenyakitPage extends StatefulWidget {
  const AdminKelolaPenyakitPage({super.key});

  @override
  State<AdminKelolaPenyakitPage> createState() =>
      _AdminKelolaPenyakitPageState();
}

class _AdminKelolaPenyakitPageState extends State<AdminKelolaPenyakitPage> {
  List penyakit = [];
  bool isLoading = true;

  final String baseUrl = "http://103.247.9.235:5000";

  @override
  void initState() {
    super.initState();
    fetchPenyakit();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> fetchPenyakit() async {
    setState(() {
      isLoading = true;
    });

    final res = await http.get(Uri.parse("$baseUrl/penyakit"));

    if (res.statusCode == 200) {
      setState(() {
        penyakit = jsonDecode(res.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deletePenyakit(int id) async {
    String? token = await getToken();

    final res = await http.delete(
      Uri.parse("$baseUrl/admin/penyakit/$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      fetchPenyakit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Penyakit berhasil dihapus")),
      );
    }
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Hapus Penyakit"),
            content: const Text("Apakah yakin ingin menghapus penyakit ini?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  deletePenyakit(id);
                },
                child: const Text("Hapus", style: TextStyle(color: Colors.red)),
              ),
            ],
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

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 55, 20, 30),
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
            child: const Padding(
              padding: EdgeInsets.only(top: 5, left: 10),
              child: Text(
                "Kelola Penyakit",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminTambahPenyakit(),
                    ),
                  );

                  if (result == true) {
                    fetchPenyakit();
                  }
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Tambah Penyakit",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: penyakit.length,
                      itemBuilder: (context, index) {
                        final item = penyakit[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child:
                                    item['gambar_url'] != null
                                        ? Image.network(
                                          item['gambar_url'],
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        )
                                        : Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image),
                                        ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['nama'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),

                                    const SizedBox(height: 5),
                                    Html(
                                      data: item['deskripsi'] ?? "",
                                      style: {
                                        "body": Style(
                                          margin: Margins.zero,
                                          padding: HtmlPaddings.zero,
                                          color: Colors.grey[700],
                                          maxLines: 3,
                                          textOverflow: TextOverflow.ellipsis,
                                        ),
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => EditPenyakitPage(
                                                penyakit: item,
                                              ),
                                        ),
                                      );

                                      if (result == true) {
                                        fetchPenyakit();
                                      }
                                    },
                                  ),

                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => confirmDelete(item['id']),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
