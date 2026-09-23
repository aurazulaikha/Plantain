import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';

class DetailRiwayatPage extends StatefulWidget {
  final Map<String, dynamic> riwayat;

  const DetailRiwayatPage({super.key, required this.riwayat});

  @override
  State<DetailRiwayatPage> createState() => _DetailRiwayatPageState();
}

class _DetailRiwayatPageState extends State<DetailRiwayatPage> {
  final String backendUrl = 'http://103.247.9.235:5000';

  Map<String, dynamic>? penyakitDetail;

  @override
  void initState() {
    super.initState();

    ambilDetailPenyakit();
  }

  Future<void> ambilDetailPenyakit() async {
    String namaPenyakit = widget.riwayat['jenis_penyakit'] ?? '';

    if (namaPenyakit == 'Sehat' || namaPenyakit == 'no_leaf') {
      return;
    }

    try {
      final response = await http.get(Uri.parse('$backendUrl/penyakit'));

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);

        final penyakit = data.firstWhere(
          (item) => item['nama'] == namaPenyakit,
          orElse: () => null,
        );

        if (penyakit != null) {
          setState(() {
            penyakitDetail = penyakit;
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal mengambil detail penyakit: $e");
    }
  }

  Widget buildSectionCard({required String title, required String content}) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xFFC8E6C9).withOpacity(0.35),

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: const Color(0xFF43A047).withOpacity(0.25)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),

          const SizedBox(height: 8),

          Html(
            data: content,
            style: {
              "body": Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                fontSize: FontSize(14),
                lineHeight: const LineHeight(1.5),
                color: Colors.black87,
              ),
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkGreen = const Color(0xFF1B5E20);

    final lightGreen = const Color(0xFFC8E6C9);

    final primaryGreen = const Color(0xFF43A047);

    final greyBg = Colors.grey.shade100;

    // Nama penyakit
    String namaPenyakit =
        widget.riwayat['jenis_penyakit'] == "no_leaf"
            ? "Gambar bukan termasuk kategori penyakit daun pisang yang dideteksi"
            : (widget.riwayat['jenis_penyakit'] ?? "-");

    // Waktu deteksi
    String waktuDeteksi = widget.riwayat['waktu_deteksi'] ?? "";

    // Confidence
    double? confidence =
        widget.riwayat['confidence'] != null
            ? double.tryParse(widget.riwayat['confidence'].toString())
            : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      body: Column(
        children: [
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
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),

                  icon: Icon(Icons.arrow_back, color: darkGreen, size: 28),
                ),

                const SizedBox(width: 10),

                Text(
                  "Detail Riwayat",

                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [
                  Container(
                    height: 260,

                    decoration: BoxDecoration(
                      color: greyBg,

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),

                      child:
                          widget.riwayat['image_url'] != null
                              ? InteractiveViewer(
                                minScale: 1,
                                maxScale: 4,

                                child: Image.network(
                                  widget.riwayat['image_url'],

                                  fit: BoxFit.contain,

                                  width: double.infinity,
                                ),
                              )
                              : const Center(
                                child: Icon(Icons.image, size: 100),
                              ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(18),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),

                          blurRadius: 10,

                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        // NAMA PENYAKIT
                        Text(
                          namaPenyakit,

                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // CONFIDENCE
                        if (confidence != null)
                          Text(
                            "Confidence: ${confidence.toStringAsFixed(2)}%",

                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),

                        const SizedBox(height: 10),

                        // WAKTU
                        if (waktuDeteksi.isNotEmpty)
                          Text(
                            waktuDeteksi,

                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // DETAIL PENYAKIT
                  if (penyakitDetail != null &&
                      widget.riwayat['jenis_penyakit'] != 'Sehat' &&
                      widget.riwayat['jenis_penyakit'] != 'no_leaf')
                    Container(
                      width: double.infinity,

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(20),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),

                            blurRadius: 8,

                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),

                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),

                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 6,
                          ),

                          childrenPadding: const EdgeInsets.fromLTRB(
                            18,
                            0,
                            18,
                            18,
                          ),

                          iconColor: darkGreen,

                          collapsedIconColor: darkGreen,

                          title: Text(
                            penyakitDetail!['nama'] ?? '-',

                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: darkGreen,
                            ),
                          ),

                          children: [
                            buildSectionCard(
                              title: "Deskripsi",

                              content: penyakitDetail!['deskripsi'] ?? '-',
                            ),

                            buildSectionCard(
                              title: "Gejala",

                              content: penyakitDetail!['gejala'] ?? '-',
                            ),

                            buildSectionCard(
                              title: "Pencegahan",

                              content: penyakitDetail!['pencegahan'] ?? '-',
                            ),

                            buildSectionCard(
                              title: "Cara Pengendalian",

                              content: penyakitDetail!['mengatasi'] ?? '-',
                            ),

                            buildSectionCard(
                              title: "Bahaya",

                              content: penyakitDetail!['bahaya'] ?? '-',
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
