import 'package:flutter/material.dart';

void main() {
  runApp(const RbePosApp());
}

class RbePosApp extends StatelessWidget {
  const RbePosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RBE POS - Kasir Pintar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Inter',
      ),
      home: const RoleSelectPage(),
    );
  }
}

// Global Database Storage
class AppDatabase {
  static List<Map<String, dynamic>> transactions = [];
  static List<Map<String, dynamic>> products = [
    {
      'id': 1,
      'name': 'Nasi goreng kampung',
      'stock': 50,
      'category': 'Food',
      'hpp': 15000,
      'price': 21600,
    },
    {
      'id': 2,
      'name': 'Es Teh Manis',
      'stock': 100,
      'category': 'Beverage',
      'hpp': 3000,
      'price': 5000,
    },
  ];
  static List<Map<String, dynamic>> shiftHistory = [
    {
      'date': '2026-10-23',
      'kasir': 'Budi Santoso',
      'shift': 'Pagi (08:00 - 16:00)',
      'omset': 21600,
    }
  ];
  static String activeOtp = "889922"; // OTP Admin untuk Void
}

// 1. HALAMAN PILIH MODE LOGIN
class RoleSelectPage extends StatelessWidget {
  const RoleSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.store, size: 48, color: Color(0xFF1E3A8A)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'RBE POS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pilih Mode Masuk Aplikasi',
                style: TextStyle(fontSize: 14, color: Color(0xFF93C5FD)),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(role: 'kasir'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person),
                  label: const Text(
                    'Login Kasir (Key / PIN)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF2563EB)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(role: 'admin'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text(
                    'Login Device Utama (Admin)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'Powered by PT. RELIABLE BASED ENTERPRISE',
                style: TextStyle(fontSize: 12, color: Color(0xFF93C5FD)),
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
  String pinInput = "";

  void pressPin(String num) {
    if (pinInput.length < 6) {
      setState(() {
        pinInput += num;
      });
      if (pinInput.length == 6) {
        Future.delayed(const Duration(milliseconds: 300), validatePin);
      }
    }
  }

  void deletePin() {
    if (pinInput.isNotEmpty) {
      setState(() {
        pinInput = pinInput.substring(0, pinInput.length - 1);
      });
    }
  }

  void clearPin() {
    setState(() {
      pinInput = "";
    });
  }

  void validatePin() {
    if (widget.role == 'admin' && pinInput == "999999") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainDashboard(isAdmin: true),
        ),
      );
    } else if (widget.role == 'kasir' && pinInput == "123456") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainDashboard(isAdmin: false),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN Salah! Coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
      clearPin();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = widget.role == 'admin';
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RoleSelectPage(),
                        ),
                      );
                    },
                  ),
                  Text(
                    isAdmin ? 'Login Device Utama (Admin)' : 'Login Kasir',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.key, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                isAdmin ? 'PIN Admin Utama' : 'PIN Kasir',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isAdmin ? 'Default PIN: 999999' : 'Default PIN: 123456',
                style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 12),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  bool filled = index < pinInput.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      color: filled ? Colors.white : Colors.transparent,
                    ),
                  );
                }),
              ),
              const Spacer(),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  for (var i = 1; i <= 9; i++)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => pressPin(i.toString()),
                      child: Text(
                        i.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  TextButton(
                    onPressed: clearPin,
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        color: Color(0xFF93C5FD),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => pressPin('0'),
                    child: const Text(
                      '0',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.backspace, color: Colors.white),
                    onPressed: deletePin,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// 3. DASHBOARD UTAMA
class MainDashboard extends StatefulWidget {
  final bool isAdmin;
  const MainDashboard({super.key, required this.isAdmin});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  String currentView = 'pos'; // 'pos', 'rekap', 'rekapkasir', 'riwayat', 'shift'
  List<Map<String, dynamic>> cart = [];
  String searchQuery = "";

  double get cartTotal =>
      cart.fold(0, (sum, item) => sum + (item['price'] * (item['qty'] as num)));
  
  // Diperbaiki agar aman dari error tipe data num/int
  int get cartCount =>
      cart.fold<int>(0, (sum, item) => sum + (item['qty'] as num).toInt());

  void addToCart(Map<String, dynamic> p) {
    setState(() {
      int index = cart.indexWhere((item) => item['name'] == p['name']);
      if (index >= 0) {
        cart[index]['qty']++;
      } else {
        cart.add({
          'name': p['name'],
          'price': p['price'],
          'hpp': p['hpp'],
          'qty': 1,
        });
      }
    });
  }

  void processPayment() {
    double total = cartTotal;
    double totalHpp = cart.fold(
      0,
      (sum, item) => sum + ((item['hpp'] ?? 0) * (item['qty'] as num)),
    );

    String trxId = "TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

    Map<String, dynamic> newTx = {
      'id': trxId,
      'time': DateTime.now().toString(),
      'kasir': "Budi Santoso",
      'items': List.from(cart),
      'total': total,
      'total_hpp': totalHpp,
      'profit': total - totalHpp,
      'method': 'Cash',
      'voided': false,
    };

    AppDatabase.transactions.add(newTx);
    setState(() {
      cart.clear();
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Transaksi Berhasil!'),
        content: Text('ID: $trxId\nTotal: Rp $total'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Fungsi Request Void dengan OTP Admin
  void requestVoidTransaction(Map<String, dynamic> tx) {
    TextEditingController otpController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Void Transaksi (Minta OTP Admin)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('No Transaksi yang akan di-void:'),
            SelectableText(
              tx['id'],
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 12),
            const Text(
              'Info: OTP aktif muncul di device admin (OTP simulasi: 889922)',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Masukkan Kode OTP Admin',
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (otpController.text == AppDatabase.activeOtp) {
                setState(() {
                  tx['voided'] = true;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaksi berhasil di-void!'), backgroundColor: Colors.red),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kode OTP Salah!'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Konfirmasi Void', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        title: Text(
          currentView == 'pos'
              ? 'Point of Sale'
              : currentView == 'rekap'
              ? 'Detail Rekapitulasi'
              : currentView == 'riwayat'
              ? 'Riwayat Transaksi'
              : currentView == 'shift'
              ? 'Riwayat Shift Kasir'
              : 'Laporan Omset Per Kasir',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1E3A8A)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.store, color: Colors.white, size: 36),
                  const SizedBox(height: 8),
                  const Text(
                    'RBE POS Utama',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    widget.isAdmin
                        ? 'Device Utama (Admin)'
                        : 'Kasir: Budi Santoso',
                    style: const TextStyle(
                      color: Color(0xFF93C5FD),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale),
              title: const Text('Point of Sale'),
              onTap: () {
                setState(() => currentView = 'pos');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Riwayat Transaksi'),
              onTap: () {
                setState(() => currentView = 'riwayat');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Riwayat Shift'),
              onTap: () {
                setState(() => currentView = 'shift');
                Navigator.pop(context);
              },
            ),
            if (!widget.isAdmin)
              ListTile(
                leading: const Icon(Icons.pie_chart),
                title: const Text('Rekapitulasi'),
                onTap: () {
                  setState(() => currentView = 'rekap');
                  Navigator.pop(context);
                },
              ),
            if (widget.isAdmin)
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Laporan Omset Per Kasir'),
                onTap: () {
                  setState(() => currentView = 'rekapkasir');
                  Navigator.pop(context);
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Keluar / Ganti Akun',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RoleSelectPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: currentView == 'pos'
          ? buildPosView()
          : currentView == 'riwayat'
              ? buildRiwayatView()
              : currentView == 'shift'
                  ? buildShiftView()
                  : currentView == 'rekap'
                      ? buildRekapView()
                      : buildAdminRekapView(),
    );
  }

  Widget buildPosView() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: AppDatabase.products.length,
            itemBuilder: (context, index) {
              var p = AppDatabase.products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      p['name'][0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    p['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Stock: ${p['stock']}'),
                  trailing: Text(
                    'Rp ${p['price']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  onTap: () => addToCart(p),
                ),
              );
            },
          ),
        ),
        if (cartCount > 0)
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: processPayment,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      'Charge ($cartCount item)',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Text(
                      'Rp $cartTotal',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Tampilan Riwayat Transaksi + Fitur Search & Void
  Widget buildRiwayatView() {
    var filteredList = AppDatabase.transactions.where((t) {
      return t['id'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          t['kasir'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            onChanged: (val) => setState(() => searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Cari No Transaksi / Nama Kasir...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: filteredList.isEmpty
              ? const Center(child: Text('Tidak ada riwayat transaksi.'))
              : ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    var tx = filteredList[index];
                    bool isVoid = tx['voided'] ?? false;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text('${tx['id']} - ${tx['kasir']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: isVoid ? TextDecoration.lineThrough : null,
                            )),
                        subtitle: Text('Total: Rp ${tx['total']} | ${tx['time']}\nStatus: ${isVoid ? "VOIDED" : "Sukses"}'),
                        isThreeLine: true,
                        trailing: !isVoid
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () => requestVoidTransaction(tx),
                                child: const Text('Void', style: TextStyle(color: Colors.white)),
                              )
                            : const Text('Batal', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Tampilan Riwayat Shift Kasir
  Widget buildShiftView() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: AppDatabase.shiftHistory.length,
      itemBuilder: (context, index) {
        var shift = AppDatabase.shiftHistory[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: const Icon(Icons.schedule, color: Colors.blue),
            title: Text('Kasir: ${shift['kasir']}'),
            subtitle: Text('Tanggal: ${shift['date']}\nShift: ${shift['shift']}'),
            trailing: Text('Rp ${shift['omset']}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ),
        );
      },
    );
  }

  Widget buildRekapView() {
    double totalOmset = AppDatabase.transactions
        .where((t) => !(t['voided'] ?? false))
        .fold(0, (sum, item) => sum + (item['total'] as double));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Status Shift',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Divider(),
              const Text('Shift Awal: 00.20'),
              const Text('Shift Akhir: Sedang Berlangsung',
                  style: TextStyle(color: Colors.amber)),
              const SizedBox(height: 16),
              Text('Total Omset: Rp $totalOmset',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }

  // Laporan Admin + Tombol Hapus Kasir
  Widget buildAdminRekapView() {
    if (AppDatabase.transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Belum ada data transaksi dari kasir.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    Map<String, Map<String, dynamic>> kasirMap = {};
    for (var t in AppDatabase.transactions) {
      if (t['voided'] ?? false) continue;
      String kasir = t['kasir'];
      if (!kasirMap.containsKey(kasir)) {
        kasirMap[kasir] = {'count': 0, 'omset': 0.0, 'profit': 0.0};
      }
      kasirMap[kasir]!['count'] += 1;
      kasirMap[kasir]!['omset'] += t['total'];
      kasirMap[kasir]!['profit'] += t['profit'];
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: kasirMap.entries.map((entry) {
        String kasirName = entry.key;
        var data = entry.value;
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(kasirName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          AppDatabase.transactions.removeWhere((t) => t['kasir'] == kasirName);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Data kasir $kasirName berhasil dihapus!')),
                        );
                      },
                    ),
                  ],
                ),
                const Divider(),
                Text('Total Transaksi: ${data['count']}'),
                Text('Total Omset: Rp ${data['omset']}'),
                Text('Keuntungan: Rp ${data['profit']}',
                    style: const TextStyle(color: Colors.green)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
