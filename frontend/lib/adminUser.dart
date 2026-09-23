import 'dart:convert';
import 'package:flutter/material.dart';
import 'adminTambah.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminUserPage extends StatefulWidget {
  const AdminUserPage({super.key});

  @override
  State<AdminUserPage> createState() => _AdminUserPageState();
}

class _AdminUserPageState extends State<AdminUserPage> {
  List users = [];
  bool isLoading = true;

  int currentPage = 0;
  final int perPage = 10;

  final String baseUrl = "http://103.247.9.235:5000";

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);

    String? token = await getToken();

    final res = await http.get(
      Uri.parse("$baseUrl/admin/users"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      setState(() {
        users = jsonDecode(res.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateRole(int id, String role) async {
    String? token = await getToken();

    await http.put(
      Uri.parse("$baseUrl/admin/users/$id/role"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"role": role}),
    );

    fetchUsers();
  }

  Future<void> deleteUser(int id) async {
    String? token = await getToken();

    await http.delete(
      Uri.parse("$baseUrl/admin/users/$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    fetchUsers();
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus User"),
        content: const Text("Yakin ingin menghapus user ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteUser(id);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget roleWidget(Map user) {
    final isAdmin = user['role'] == "admin";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isAdmin
            ? const Color(0xFF43A047).withOpacity(0.15)
            : Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAdmin ? const Color(0xFF43A047) : Colors.orange,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: user['role'],
          isDense: true,
          icon: const Icon(Icons.arrow_drop_down, size: 18),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isAdmin ? const Color(0xFF43A047) : Colors.orange,
          ),
          items: const [
            DropdownMenuItem(value: "user", child: Text("User")),
            DropdownMenuItem(value: "admin", child: Text("Admin")),
          ],
          onChanged: (value) {
            if (value != null) {
              updateRole(user['id'], value);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF1B5E20);
    const lightGreen = Color(0xFFC8E6C9);
    const primaryGreen = Color(0xFF43A047);

    int start = currentPage * perPage;
    int end = start + perPage;

    List paginated = users.sublist(
      start,
      end > users.length ? users.length : end,
    );

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
            child: Padding(
              padding: const EdgeInsets.only(top: 5, left: 10),
              child: Text(
                "Kelola User",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // BUTTON TAMBAH ADMIN
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
                      builder: (_) => const AdminTambah(),
                    ),
                  );

                  if (result == true) fetchUsers();
                },
                icon: const Icon(Icons.person_add, color: Colors.white),
                label: const Text(
                  "Tambah Admin",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // LIST USER 
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: paginated.length,
                    itemBuilder: (context, index) {
                      final user = paginated[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user['nama'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(user['email']),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text("Role: "),
                                      roleWidget(user),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => confirmDelete(user['id']),
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),

          //  PAGINATION 
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: currentPage > 0
                      ? () => setState(() => currentPage--)
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  "${currentPage + 1}",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                IconButton(
                  onPressed: end < users.length
                      ? () => setState(() => currentPage++)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}