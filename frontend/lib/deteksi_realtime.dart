import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_html/flutter_html.dart';

class RealtimeDetectionPage extends StatefulWidget {
  const RealtimeDetectionPage({super.key});

  @override
  State<RealtimeDetectionPage> createState() => _RealtimeDetectionPageState();
}

class _RealtimeDetectionPageState extends State<RealtimeDetectionPage> {
  CameraController? _controller;
  bool _isDetecting = false;
  bool _isLoggedIn = false;
  Timer? _timer;
  String? _hasilPrediksi;
  String _waktuDeteksi = '';
  double? _confidence;
  double? _inferenceTime;

  Map<String, dynamic>? _penyakitDetail;
  String? jwtToken;
  final String backendUrl = 'http://103.247.9.235:5000';

  @override
  void initState() {
    super.initState();
    _cekTokenLokal();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tampilkanPopupPetunjuk();
    });
  }

  Future<void> _cekTokenLokal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');

    if (token != null) {
      jwtToken = token;

      setState(() {
        _isLoggedIn = true;
      });

      await _initCamera();
    }
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    CameraDescription? camera;

    for (var cam in cameras) {
      if (cam.lensDirection == CameraLensDirection.back) {
        camera = cam;
        break;
      }
    }

    camera ??= cameras.first;
    _controller = CameraController(camera, ResolutionPreset.medium);
    await _controller!.initialize();
    await _controller!.setFlashMode(FlashMode.off);
    setState(() {});

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _ambilDanKirimFrame(),
    );
  }

  Future<void> _ambilDanKirimFrame() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isDetecting) {
      return;
    }

    try {
      _isDetecting = true;
      final XFile file = await _controller!.takePicture();
      File imageFile = File(file.path);
      await _kirimKeAPI(imageFile);
    } catch (e) {
      debugPrint("Error ambil frame: $e");
    } finally {
      _isDetecting = false;
    }
  }

  Future<void> _kirimKeAPI(File imageFile) async {
    if (jwtToken == null) return;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$backendUrl/predict/realtime'),
      );
      request.headers['Authorization'] = 'Bearer $jwtToken';
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var response = await request.send();
      var responseString = await response.stream.bytesToString();
      var jsonData = jsonDecode(responseString);

      if (response.statusCode == 200) {
        String label = jsonData['label'];

        setState(() {
          _hasilPrediksi = tampilkanLabel(label);
          _confidence = jsonData['confidence'];
          _inferenceTime = jsonData['inference_time'];
          _waktuDeteksi = DateTime.now().toString();
        });

        await _ambilDetailPenyakit(label);
      } else {
        setState(() {
          _hasilPrediksi = 'Deteksi gagal (${response.statusCode})';
          _confidence = null;
          _inferenceTime = null;
          _waktuDeteksi = '';
          _penyakitDetail = null;
        });

        debugPrint("Response error: $responseString");
      }
    } catch (e) {
      debugPrint("Gagal kirim ke API: $e");
      setState(() {
        _hasilPrediksi = 'Error koneksi';
        _confidence = null;
        _inferenceTime = null;
        _waktuDeteksi = '';
        _penyakitDetail = null;
      });
    }
  }

  Future<void> _ambilDetailPenyakit(String namaPenyakit) async {
    if (namaPenyakit == 'Healthy' || namaPenyakit == 'no_leaf') {
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
            _penyakitDetail = penyakit;
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal ambil detail penyakit: $e");
    }
  }

  String tampilkanLabel(String label) {
    switch (label) {
      case 'Healthy':
        return 'Sehat';
      case 'no_leaf':
        return 'Gambar bukan termasuk kategori penyakit daun pisang yang dideteksi';

      default:
        return label;
    }
  }

  void _tampilkanPopupPetunjuk() {
    final darkGreen = const Color(0xFF1B5E20);
    final lightGreen = const Color(0xFFC8E6C9);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt_rounded, size: 60, color: darkGreen),

                  const SizedBox(height: 15),

                  Text(
                    "Petunjuk Pengambilan Gambar",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildPetunjukItem(
                    icon: Icons.check_circle,
                    text:
                        "Pastikan daun pisang terlihat jelas dan fokus. Posisikan kamera sejajar dengan permukaan daun.",
                    color: Colors.green,
                  ),

                  _buildPetunjukItem(
                    icon: Icons.wb_sunny,
                    text:
                        "Gunakan pencahayaan yang cukup dan merata agar gambar tidak gelap.",
                    color: Colors.orange,
                  ),

                  _buildPetunjukItem(
                    icon: Icons.crop_free,
                    text: "Posisikan daun memenuhi area gambar.",
                    color: Colors.blue,
                  ),

                  _buildPetunjukItem(
                    icon: Icons.block,
                    text:
                        "Hindari gambar buram, terlalu dekat, atau terlalu jauh. Berikan jarak ideal sekitar 20-40 cm",
                    color: Colors.red,
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightGreen,
                        foregroundColor: darkGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Mengerti",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPetunjukItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox({
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),

            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required String content}) {
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
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkGreen = const Color(0xFF1B5E20);
    final lightGreen = const Color(0xFFC8E6C9);
    final primaryGreen = const Color(0xFF43A047);

    if (!_isLoggedIn) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const Text(
                "Token tidak ditemukan. Silakan login terlebih dahulu.",
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/login");
                },
                child: const Text("Ke Halaman Login"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
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
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: darkGreen, size: 28),
                  ),

                  const SizedBox(width: 10),

                  Text(
                    "Deteksi Realtime",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // CAMERA FRAME
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primaryGreen, width: 2),
                    ),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child:
                          _controller == null ||
                                  !_controller!.value.isInitialized
                              ? const Center(child: CircularProgressIndicator())
                              : CameraPreview(_controller!),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // HASIL DETEKSI
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Hasil Deteksi",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 14,
                          ),

                          decoration: BoxDecoration(
                            color: lightGreen.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(14),
                          ),

                          child: Text(
                            _hasilPrediksi ?? "Sedang mendeteksi...",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: darkGreen,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            if (_confidence != null)
                              _buildInfoBox(
                                title: "Confidence",
                                value: "${_confidence!.toStringAsFixed(2)}%",
                                color: const Color.fromARGB(255, 79, 74, 187),
                              ),
                            if (_confidence != null && _inferenceTime != null)
                              const SizedBox(width: 10),
                            if (_inferenceTime != null)
                              _buildInfoBox(
                                title: "Inference",
                                value:
                                    "${_inferenceTime!.toStringAsFixed(4)} s",
                                color: Colors.orange,
                              ),
                          ],
                        ),
                        if (_waktuDeteksi.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            "Waktu Deteksi: $_waktuDeteksi",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // DETAIL PENYAKIT
                  if (_penyakitDetail != null &&
                      _hasilPrediksi != 'Sehat' &&
                      _hasilPrediksi !=
                          'Gambar bukan termasuk kategori penyakit daun pisang yang dideteksi')
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
                            _penyakitDetail!['nama'] ?? '-',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: darkGreen,
                            ),
                          ),

                          children: [
                            _buildSectionCard(
                              title: "Deskripsi",
                              content: _penyakitDetail!['deskripsi'] ?? '-',
                            ),

                            _buildSectionCard(
                              title: "Gejala",
                              content: _penyakitDetail!['gejala'] ?? '-',
                            ),

                            _buildSectionCard(
                              title: "Pencegahan",
                              content: _penyakitDetail!['pencegahan'] ?? '-',
                            ),

                            _buildSectionCard(
                              title: "Cara Pengendalian",
                              content: _penyakitDetail!['mengatasi'] ?? '-',
                            ),

                            _buildSectionCard(
                              title: "Bahaya",
                              content: _penyakitDetail!['bahaya'] ?? '-',
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
