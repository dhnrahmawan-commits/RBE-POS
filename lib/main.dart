import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const RbePosApp());
}

class RbePosApp extends StatelessWidget {
  const RbePosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RBE POS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Inter',
      ),
      home: const RoleSelectPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// 1. HALAMAN PILIH MODE LOGIN
class RoleSelectPage extends StatelessWidget {
  const RoleSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    'https://i.ibb.co.com/6X2m29Q/1000014612.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.point_of_sale, size: 40, color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text("RBE POS", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
              const Text("Pilih Mode Masuk Aplikasi", style: TextStyle(fontSize: 13, color: Colors.blueAccent)),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage(role: 'kasir'))),
                icon: const Icon(Icons.person, color: Colors.blue),
                label: const Text("Login Kasir", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage(role: 'admin'))),
                icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
                label: const Text("Login Admin", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const Spacer(),
              const Text(
                "Powered by PT. RELIABLE BASED ENTERPRISE",
                style: TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 2. HALAMAN INPUT PIN
class LoginPage extends StatefulWidget {
  final String role;
  const LoginPage({super.key, required this.role});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _pinController = TextEditingController();

  void _validatePin() {
    String pin = _pinController.text;
    if (widget.role == 'kasir' && pin == '123456') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const KasirHomePage()));
    } else if (widget.role == 'admin' && pin == '999999') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminReportPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PIN Salah! Coba lagi.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = widget.role == 'admin';
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 70, color: Colors.white),
            const SizedBox(height: 16),
            Text(isAdmin ? "Login Admin" : "Login Kasir", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 30),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 8),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                hintText: "••••••",
                hintStyle: const TextStyle(color: Colors.white38),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                counterText: "",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _validatePin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade900,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Masuk", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. HALAMAN KASIR (POINT OF SALE)
class KasirHomePage extends StatefulWidget {
  const KasirHomePage({super.key});

  @override
  State<KasirHomePage> createState() => _KasirHomePageState();
}

class _KasirHomePageState extends State<KasirHomePage> {
  final List<Map<String, dynamic>> products = [
    {"name": "Nasi Goreng Kampung", "price": 21600, "hpp": 15000},
    {"name": "Nasi Goreng Spesial", "price": 25000, "hpp": 18000},
    {"name": "Es Teh Manis", "price": 5000, "hpp": 3000},
  ];

  final List<Map<String, dynamic>> cart = [];

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      cart.add({"name": product["name"], "price": product["price"], "hpp": product["hpp"], "qty": 1, "notes": ""});
    });
  }

  Future<void> _checkout() async {
    if (cart.isEmpty) return;
    int total = cart.fold(0, (sum, item) => sum + (item["price"] as int) * (item["qty"] as int));
    int totalHpp = cart.fold(0, (sum, item) => sum + (item["hpp"] as int) * (item["qty"] as int));

    Map<String, dynamic> txData = {
      "id": "TRX-${DateTime.now().millisecondsSinceEpoch}",
      "time": DateTime.now().toIso8601String(),
      "kasir": "Budi Santoso",
      "items": cart,
      "total": total,
      "totalHpp": totalHpp,
      "profit": total - totalHpp,
      "method": "Cash",
    };

    try {
      // Alamat URL backend (Gunakan 10.0.2.2 jika di Emulator Android)
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/transactions'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(txData),
      );

      if (response.statusCode == 201) {
        setState(() => cart.clear());
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Berhasil!"),
            content: const Text("Transaksi berhasil diproses & disinkronkan ke database server."),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal terhubung ke server: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalCart = cart.fold(0, (sum, item) => sum + (item["price"] as int) * (item["qty"] as int));
    return Scaffold(
      appBar: AppBar(title: const Text("RBE POS - Kasir"), backgroundColor: Colors.blue.shade900),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade900),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("RBE POS Utama", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Kasir: Budi Santoso", style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
                ],
              ),
            ),
            const Spacer(),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text("Licensed to", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  Text("PT. RELIABLE BASED ENTERPRISE", style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                return Card(
                  color: Colors.white.withOpacity(0.05),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(p["name"], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    subtitle: Text("Rp ${p["price"]} | Stok: 50", style: const TextStyle(color: Colors.white70)),
                    trailing: ElevatedButton(
                      onPressed: () => _addToCart(p),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900),
                      child: const Text("Tambah", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total: Rp $totalCart", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: cart.isEmpty ? null : _checkout,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Bayar / Charge", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// 4. HALAMAN LAPORAN OMSET ADMIN (TERSINKRON DATABASE)
class AdminReportPage extends StatefulWidget {
  const AdminReportPage({super.key});

  @override
  State<AdminReportPage> createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> {
  List transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/transactions'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          transactions = data["data"];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Omset Per Kasir (Admin)"),
        backgroundColor: Colors.blue.shade900,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchTransactions)
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? const Center(child: Text("Belum ada data transaksi dari kasir.", style: TextStyle(color: Colors.white70)))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(tx["id"], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                                Text("Kasir: ${tx["kasir"]}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const Divider(),
                            Text("Total Omset: Rp ${tx["total"]}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text("Keuntungan (Profit): Rp ${tx["profit"]}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("Waktu: ${tx["time"]}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
