import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class DetailPenyakitPage extends StatelessWidget {
  final Map<String, dynamic> penyakit;

  const DetailPenyakitPage({super.key, required this.penyakit});

  @override
  Widget build(BuildContext context) {
    final darkGreen = const Color(0xFF1B5E20);

    final lightGreen = const Color(0xFFC8E6C9);

    if (penyakit.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Data penyakit tidak tersedia")),
      );
    }

    String nama = penyakit['nama']?.toString() ?? "-";
    String deskripsi = penyakit['deskripsi']?.toString() ?? "-";
    String gejala = penyakit['gejala']?.toString() ?? "-";
    String pencegahan = penyakit['pencegahan']?.toString() ?? "-";
    String mengatasi = penyakit['mengatasi']?.toString() ?? "-";
    String bahaya = penyakit['bahaya']?.toString() ?? "-";
    String gambarUrl = penyakit['gambar_url']?.toString() ?? "";

    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,

                height: 200,

                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(35),

                    bottomRight: Radius.circular(35),
                  ),

                  color: lightGreen,

                  image:
                      gambarUrl.isNotEmpty
                          ? DecorationImage(
                            image: NetworkImage(gambarUrl),

                            fit: BoxFit.cover,
                          )
                          : null,
                ),
              ),

              Container(
                width: double.infinity,

                height: 200,

                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(35),

                    bottomRight: Radius.circular(35),
                  ),

                  gradient: LinearGradient(
                    begin: Alignment.topCenter,

                    end: Alignment.bottomCenter,

                    colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                  ),
                ),
              ),

              Positioned(
                left: 16,

                bottom: 16,

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,

                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),

                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Text(
                      nama,

                      style: const TextStyle(
                        fontSize: 26,

                        fontWeight: FontWeight.bold,

                        color: Colors.white,

                        shadows: [
                          Shadow(
                            color: Colors.black54,

                            offset: Offset(1, 1),

                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  _fancySectionCard(
                    "Deskripsi",
                    deskripsi,
                    darkGreen,
                    Icons.info,
                  ),

                  if (nama != "Sehat") ...[
                    const SizedBox(height: 12),

                    _fancySectionCard(
                      "Gejala",
                      gejala,
                      darkGreen,
                      Icons.medical_services,
                    ),

                    const SizedBox(height: 12),

                    _fancySectionCard(
                      "Pencegahan",
                      pencegahan,
                      darkGreen,
                      Icons.shield,
                    ),

                    const SizedBox(height: 12),

                    _fancySectionCard(
                      "Cara Pengendalian",
                      mengatasi,
                      darkGreen,
                      Icons.build,
                    ),

                    const SizedBox(height: 12),

                    _fancySectionCard(
                      "Bahaya",
                      bahaya,
                      darkGreen,
                      Icons.warning,
                    ),
                  ],

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fancySectionCard(
    String title,
    String content,
    Color darkGreen,
    IconData icon,
  ) {
    return Card(
      color: Colors.white,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      elevation: 4,

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Icon(icon, color: darkGreen),

                const SizedBox(width: 8),

                Text(
                  title,

                  style: TextStyle(
                    fontSize: 18,

                    fontWeight: FontWeight.bold,

                    color: darkGreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Html(
              data: content,
              style: {
                "body": Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  fontSize: FontSize(15),
                  lineHeight: const LineHeight(1.4),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
//