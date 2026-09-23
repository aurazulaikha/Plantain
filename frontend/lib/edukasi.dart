import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detailEdukasi.dart';
import 'package:flutter_html/flutter_html.dart';

class EdukasiPage extends StatefulWidget {
  const EdukasiPage({super.key});

  @override
  State<EdukasiPage> createState() => _EdukasiPageState();
}

class _EdukasiPageState extends State<EdukasiPage> {
  List<dynamic> penyakitList = [];
  bool isLoading = true;
  final String baseUrl = "http://103.247.9.235:5000";

  @override
  void initState() {
    super.initState();
    fetchPenyakit();
  }

  Future<void> fetchPenyakit() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/penyakit"));

      if (response.statusCode == 200) {
        setState(() {
          penyakitList = jsonDecode(response.body);

          isLoading = false;
        });
      } else {
        print("Gagal fetch data");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryGreen = const Color(0xFF43A047);
    final darkGreen = const Color(0xFF1B5E20);
    final lightGreen = const Color(0xFFC8E6C9);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(0, 50, 20, 35),
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
                padding: const EdgeInsets.only(top: 5, left: 30),
                child: Text(
                  "Edukasi Penyakit Pisang",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // LIST PENYAKIT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLoading)
                    const Center(child: CircularProgressIndicator()),
                  for (var p in penyakitList)
                    if (p['nama'] != 'no_leaf')
                      InkWell(
                        borderRadius: BorderRadius.circular(18),

                        onTap: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) => DetailPenyakitPage(penyakit: p),
                            ),
                          );
                        },

                        child: _boxPenyakit(
                          title: p['nama'] ?? '-',
                          desc: p['deskripsi'] ?? '-',
                          imageUrl: p['gambar_url'],
                          primaryGreen: primaryGreen,
                        ),
                      ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _boxPenyakit({
    required String title,
    required String desc,
    required String? imageUrl,
    required Color primaryGreen,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: primaryGreen.withOpacity(0.35)),
        borderRadius: BorderRadius.circular(18),
        color: primaryGreen.withOpacity(0.05),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),

                const SizedBox(height: 8),

                Html(
                  data: desc,
                  style: {
                    "body": Style(
                      fontSize: FontSize(13),
                      lineHeight: const LineHeight(1.5),
                      maxLines: 3,
                      textOverflow: TextOverflow.ellipsis,
                      color: Colors.black87,
                    ),
                  },
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Text(
                      "Lihat detail",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primaryGreen,
                      ),
                    ),

                    const SizedBox(width: 5),

                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: primaryGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // IMAGE
          Container(
            width: 95,
            height: 95,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: primaryGreen.withOpacity(0.15),
            ),

            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),

              child:
                  imageUrl != null
                      ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Icon(Icons.broken_image));
                        },
                      )
                      : const Center(child: Text("No Img")),
            ),
          ),
        ],
      ),
    );
  }
}
