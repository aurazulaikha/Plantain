import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'detailRiwayat.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List<dynamic> riwayatList = [];
  bool isLoading = true;

  final String baseUrl = "http://103.247.9.235:5000";

  int currentPage = 1;
  final int perPage = 6;

  @override
  void initState() {
    super.initState();
    fetchRiwayat();
  }

  Future<void> fetchRiwayat() async {
    setState(() => isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse("$baseUrl/riwayat"),
        headers: {"Authorization": "Bearer $token"},
      );

      developer.log(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          riwayatList = data;
          isLoading = false;
        });
      } else {
        developer.log("Gagal fetch riwayat: ${response.body}");

        if (!mounted) return;

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      developer.log("Error fetch riwayat: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteRiwayat(int id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse("$baseUrl/riwayat/$id"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        setState(() {
          riwayatList.removeWhere((item) => item['id'] == id);
          int totalPages = (riwayatList.length / perPage).ceil();

          if (currentPage > totalPages && totalPages > 0) {
            currentPage = totalPages;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Riwayat berhasil dihapus")),
        );
      } else {
        developer.log("Gagal hapus: ${response.body}");
      }
    } catch (e) {
      developer.log("Error hapus riwayat: $e");
    }
  }

  Future<void> deleteAllRiwayat() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse("$baseUrl/riwayat/all"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        setState(() {
          riwayatList.clear();
          currentPage = 1;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Semua riwayat berhasil dihapus")),
        );
      } else {
        developer.log("Gagal hapus semua: ${response.body}");
      }
    } catch (e) {
      developer.log("Error delete all: $e");
    }
  }

  Future<void> confirmDelete(int id) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Konfirmasi Hapus"),
            content: const Text("Yakin ingin menghapus riwayat ini?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Tidak"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Ya"),
              ),
            ],
          ),
    );

    if (result == true) {
      deleteRiwayat(id);
    }
  }

  Future<void> confirmDeleteAll() async {
    if (riwayatList.isEmpty) return;

    bool? result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Hapus Semua Riwayat"),
            content: const Text(
              "Apakah Anda yakin ingin menghapus SEMUA riwayat deteksi?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Tidak"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Ya"),
              ),
            ],
          ),
    );

    if (result == true) {
      deleteAllRiwayat();
    }
  }

  List<dynamic> get paginatedList {
    int start = (currentPage - 1) * perPage;
    int end = start + perPage;

    if (start >= riwayatList.length) return [];

    if (end > riwayatList.length) {
      end = riwayatList.length;
    }

    return riwayatList.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final darkGreen = const Color(0xFF1B5E20);
    final lightGreen = const Color(0xFFC8E6C9);
    final primaryGreen = const Color(0xFF43A047);

    int totalPages = (riwayatList.length / perPage).ceil();

    if (totalPages == 0) {
      totalPages = 1;
    }

    return Scaffold(
      body: Column(
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
                  color: const Color.fromRGBO(0, 0, 0, 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 10),
                  child: Text(
                    "Riwayat Deteksi",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: confirmDeleteAll,
                  icon: const Icon(Icons.delete_forever, size: 30),
                  color: const Color.fromARGB(255, 193, 57, 48),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // LIST
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : riwayatList.isEmpty
                      ? const Center(child: Text("Belum ada riwayat deteksi"))
                      : ListView.builder(
                        itemCount: paginatedList.length,
                        itemBuilder: (context, index) {
                          var r = paginatedList[index];

                          double confidence =
                              double.tryParse(r['confidence'].toString()) ??
                              0.0;

                          String jenisPenyakit =
                              r['jenis_penyakit'] == 'no_leaf'
                                  ? "Gambar bukan termasuk kategori penyakit daun pisang yang dideteksi"
                                  : (r['jenis_penyakit'] ?? "Tidak diketahui");

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          DetailRiwayatPage(riwayat: r),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 55,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child:
                                        r['image_url'] != null
                                            ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                r['image_url'],
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                            : const Icon(Icons.image),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          jenisPenyakit,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: primaryGreen,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Confidence: ${confidence.toStringAsFixed(2)}%",
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          r['waktu_deteksi']?.toString() ?? "-",
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => confirmDelete(r['id']),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed:
                    currentPage > 1
                        ? () {
                          setState(() {
                            currentPage--;
                          });
                        }
                        : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text("$currentPage / $totalPages"),
              IconButton(
                onPressed:
                    currentPage < totalPages
                        ? () {
                          setState(() {
                            currentPage++;
                          });
                        }
                        : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),

          const SizedBox(height: 18),
        ],
      ),
    );
  }
}
