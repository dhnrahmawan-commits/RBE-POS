import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const RbePosApp());
}

class RbePosApp extends StatelessWidget {
  const RbePosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RBE POS - Kasir Pintar & Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Inter',
      ),
      home: const RoleSelectPage(),
    );
  }
}

class AppDatabase {
  static String storeName = "RBE POS Utama";
  static String storeAddress = "Jl. Raya Utama No. 45, Surabaya";
  static List<Map<String, dynamic>> transactions = [];
  static List<Map<String, dynamic>> products = [
    {'name': 'Nasi goreng kampung', 'category': 'Food', 'stock': 50, 'price': 21600, 'hpp': 15000},
    {'name': 'Nasi goreng teri', 'category': 'Food', 'stock': 50, 'price': 22000, 'hpp': 16000},
    {'name': 'Nasi goreng spesial', 'category': 'Food', 'stock': 50, 'price': 25000, 'hpp': 18000},
    {'name': 'Nasi goreng bakso', 'category': 'Food', 'stock': 50, 'price': 21000, 'hpp': 15000},
    {'name': 'Es Teh Manis', 'category': 'Beverage', 'stock': 100, 'price': 5000, 'hpp': 3000},
  ];
  static List<Map<String, dynamic>> cashiers = [
    {'name': 'Budi Santoso', 'branch': 'Cabang Pusat', 'pin': '123456'}
  ];
  static List<Map<String, dynamic>> connectedDevices = [
    {'deviceName': 'Tablet Kasir Utama (Device #01)', 'ip': '192.168.1.15', 'status': 'Online'}
  ];
  static List<Map<String, dynamic>> shiftHistory = [
    {'date': '2026-10-23', 'kasir': 'Budi Santoso', 'shift': 'Pagi (08:00 - 16:00)', 'omset': 21600}
  ];
  static String activeOtp = "889922";
}

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
                width: 96, height: 96,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                child: const Center(child: Icon(Icons.store, size: 48, color: Color(0xFF1E3A8A))),
              ),
              const SizedBox(height: 16),
              const Text('RBE POS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              const Text('Pilih Mode Masuk Aplikasi', style: TextStyle(fontSize: 14, color: Color(0xFF93C5FD))),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF1E3A8A), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(role: 'kasir'))),
                  icon: const Icon(Icons.person),
                  label: const Text('Login Kasir (Key / PIN)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Color(0xFF2563EB)), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(role: 'admin'))),
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Login Device Utama (Admin)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const Spacer(),
              const Text('Powered by PT. RELIABLE BASED ENTERPRISE', style: TextStyle(fontSize: 12, color: Color(0xFF93C5FD))),
            ],
          ),
        ),
      ),
    );
  }
}

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
      setState(() { pinInput += num; });
      if (pinInput.length == 6) Future.delayed(const Duration(milliseconds: 300), validatePin);
    }
  }

  void deletePin() { if (pinInput.isNotEmpty) setState(() { pinInput = pinInput.substring(0, pinInput.length - 1); }); }
  void clearPin() { setState(() { pinInput = ""; }); }

  void validatePin() {
    if (widget.role == 'admin' && pinInput == "999999") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainDashboard(isAdmin: true)));
    } else if (widget.role == 'kasir' && pinInput == "123456") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainDashboard(isAdmin: false)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN Salah! Coba lagi.'), backgroundColor: Colors.red));
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
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RoleSelectPage())),
                  ),
                  Text(isAdmin ? 'Login Device Utama (Admin)' : 'Login Kasir', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
              const Spacer(),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.key, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              Text(isAdmin ? 'PIN Admin Utama' : 'PIN Kasir', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(isAdmin ? 'Default PIN: 999999' : 'Default PIN: 123456', style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 12)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  bool filled = index < pinInput.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 16, height: 16,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), color: filled ? Colors.white : Colors.transparent),
                  );
                }),
              ),
              const Spacer(),
              GridView.count(
                crossAxisCount: 3, shrinkWrap: true, childAspectRatio: 1.5, crossAxisSpacing: 12, mainAxisSpacing: 12,
                children: [
                  for (var i = 1; i <= 9; i++)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.1), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      onPressed: () => pressPin(i.toString()),
                      child: Text(i.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  TextButton(onPressed: clearPin, child: const Text('Reset', style: TextStyle(color: Color(0xFF93C5FD), fontWeight: FontWeight.bold))),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.1), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    onPressed: () => pressPin('0'),
                    child: const Text('0', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(icon: const Icon(Icons.backspace, color: Colors.white), onPressed: deletePin),
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

class MainDashboard extends StatefulWidget {
  final bool isAdmin;
  const MainDashboard({super.key, required this.isAdmin});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  String currentView = 'pos';
  List<Map<String, dynamic>> cart = [];
  String searchQuery = "";
  String selectedCategory = "All item";

  double get cartTotal => cart.fold(0, (sum, item) => sum + ((item['price'] as num) * (item['qty'] as num)));
  int get cartCount => cart.fold<int>(0, (sum, item) => sum + (item['qty'] as num).toInt());

  void addToCart(Map<String, dynamic> p) {
    setState(() {
      int index = cart.indexWhere((item) => item['name'] == p['name']);
      if (index >= 0) {
        cart[index]['qty']++;
      } else {
        cart.add({'name': p['name'], 'price': p['price'], 'hpp': p['hpp'], 'qty': 1});
      }
    });
  }

  void openCheckout() {
    String selectedMethod = "Cash";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Rp $cartTotal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const Divider(),
                    const Text('METODE PEMBAYARAN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedMethod,
                      decoration: InputDecoration(filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                      items: ['Cash', 'QRIS All Bank', 'OVO', 'GoPay', 'DANA', 'ShopeePay', 'EDC / Kartu Bank', 'GrabFood', 'GoFood', 'ShopeeFood'].map((String val) {
                        return DropdownMenuItem<String>(value: val, child: Text(val));
                      }).toList(),
                      onChanged: (val) { setModalState(() { selectedMethod = val!; }); },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        onPressed: () {
                          Navigator.pop(context);
                          processPaymentFinal(selectedMethod);
                        },
                        child: Text('Konfirmasi Pembayaran $selectedMethod', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void processPaymentFinal(String method) {
    double total = cartTotal;
    double totalHpp = cart.fold(0, (sum, item) => sum + ((item['hpp'] ?? 0) * (item['qty'] as num)));
    String trxId = "TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

    Map<String, dynamic> newTx = {
      'id': trxId,
      'time': DateTime.now().toString(),
      'kasir': "Budi Santoso",
      'items': List.from(cart),
      'total': total,
      'total_hpp': totalHpp,
      'profit': total - totalHpp,
      'method': method,
      'voided': false,
    };

    AppDatabase.transactions.add(newTx);
    setState(() { cart.clear(); });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 64, height: 64, decoration: const BoxDecoration(color: Color(0xFFD1FAE5), shape: BoxShape.circle), child: const Icon(Icons.check, color: Color(0xFF059669), size: 36)),
              const SizedBox(height: 16),
              const Text('Transaksi Berhasil!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Rp $total', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
              Text('Metode: $method • Budi Santoso', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade100, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 48), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Struk berhasil dicetak!'))); },
                icon: const Icon(Icons.print),
                label: const Text('Cetak Struk'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD1FAE5), foregroundColor: const Color(0xFF065F46), minimumSize: const Size(double.infinity, 48), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Struk dikirim ke WhatsApp!'))); },
                icon: const Icon(Icons.chat),
                label: const Text('Kirim Struk ke WA'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () => Navigator.pop(context),
                child: const Text('Transaksi Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        title: Text(
          currentView == 'pos' ? 'Point of Sale' :
          currentView == 'rekap' ? 'Detail Rekapitulasi' :
          currentView == 'riwayat' ? 'Riwayat Penjualan' :
          currentView == 'shift' ? 'Shift Management' :
          currentView == 'printer' ? 'Setting Printer & Struk' :
          currentView == 'logdevice' ? 'Log Device' :
          currentView == 'keykasir' ? 'Key Kasir' :
          currentView == 'settingtoko' ? 'Setting Toko' :
          currentView == 'settingproduk' ? 'Setting Produk' :
          currentView == 'adminotp' ? 'Generate OTP Admin' : 'Laporan Omset Per Kasir',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
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
                  Text(AppDatabase.storeName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(widget.isAdmin ? 'Device Utama (Admin)' : 'Kasir: Budi Santoso', style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 12)),
                  const Text('Shift: Tidak Aktif', style: TextStyle(color: Color(0xFF93C5FD), fontSize: 11)),
                ],
              ),
            ),
            ListTile(leading: const Icon(Icons.point_of_sale), title: const Text('Point of Sale'), onTap: () { setState(() => currentView = 'pos'); Navigator.pop(context); }),
            if (widget.isAdmin) ...[
              ListTile(leading: const Icon(Icons.devices), title: const Text('Log Device'), onTap: () { setState(() => currentView = 'logdevice'); Navigator.pop(context); }),
              ListTile(leading: const Icon(Icons.key), title: const Text('Key Kasir'), onTap: () { setState(() => currentView = 'keykasir'); Navigator.pop(context); }),
              ListTile(leading: const Icon(Icons.bar_chart), title: const Text('Laporan Omset Per Kasir'), onTap: () { setState(() => currentView = 'adminrekap'); Navigator.pop(context); }),
              ListTile(leading: const Icon(Icons.settings), title: const Text('Setting Toko'), onTap: () { setState(() => currentView = 'settingtoko'); Navigator.pop(context); }),
              ListTile(leading: const Icon(Icons.inventory), title: const Text('Setting Produk'), onTap: () { setState(() => currentView = 'settingproduk'); Navigator.pop(context); }),
              ListTile(leading: const Icon(Icons.vpn_key), title: const Text('Generate OTP Admin'), onTap: () { setState(() => currentView = 'adminotp'); Navigator.pop(context); }),
            ] else ...[
              ListTile(leading: const Icon(Icons.pie_chart), title: const Text('Rekapitulasi'), onTap: () { setState(() => currentView = 'rekap'); Navigator.pop(context); }),
              ListTile(leading: const Icon(Icons.history), title: const Text('Riwayat Penjualan'), onTap: () { setState(() => currentView = 'riwayat'); Navigator.pop(context); }),
              ListTile(leading: const Icon(Icons.schedule), title: const Text('Shift Management'), onTap: () { setState(() => currentView = 'shift'); Navigator.pop(context); }),
              ListTile(leading: const Icon(Icons.print), title: const Text('Setting Printer & Struk'), onTap: () { setState(() => currentView = 'printer'); Navigator.pop(context); }),
            ],
            const Divider(),
            ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Keluar / Ganti Akun', style: TextStyle(color: Colors.red)), onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RoleSelectPage()))),
          ],
        ),
      ),
      body: Container(
        color: const Color(0xFFF8FAFC),
        child: currentView == 'pos' ? buildPosView() :
               currentView == 'rekap' ? buildRekapView() :
               currentView == 'riwayat' ? buildRiwayatView() :
               currentView == 'shift' ? buildShiftView() :
               currentView == 'printer' ? buildPrinterView() :
               currentView == 'logdevice' ? buildLogDeviceView() :
               currentView == 'keykasir' ? buildKeyKasirView() :
               currentView == 'settingtoko' ? buildSettingTokoView() :
               currentView == 'settingproduk' ? buildSettingProdukView() :
               currentView == 'adminotp' ? buildAdminOtpView() : buildAdminRekapView(),
      ),
    );
  }

  Widget buildPosView() {
    var filteredProducts = AppDatabase.products.where((p) {
      bool matchCat = selectedCategory == 'All item' || p['category'] == selectedCategory;
      bool matchSearch = p['name'].toLowerCase().contains(searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) => setState(() => searchQuery = val),
                    decoration: InputDecoration(hintText: 'Search...', prefixIcon: const Icon(Icons.search, color: Colors.grey), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All item', 'Discounts', 'Food', 'Beverage'].map((cat) {
                        bool isSelected = selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            selectedColor: const Color(0xFF1E3A8A),
                            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                            onSelected: (val) { setState(() { selectedCategory = cat; }); },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  var p = filteredProducts[index];
                  return Card(
                    elevation: 0, color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE2E8F0))),
                    child: ListTile(
                      leading: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: const Color(0xFF1E3A8A), borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.center,
                        child: Text(p['name'][0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                      subtitle: Text('Stock ${p['stock']}', style: const TextStyle(color: Colors.grey)),
                      trailing: Text('Rp ${p['price']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                      onTap: () => addToCart(p),
                    ),
                  );
                },
              ),
            ),
            if (cartCount > 0) const SizedBox(height: 80),
          ],
        ),
        if (cartCount > 0)
          Positioned(
            left: 16, right: 16, bottom: 16,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 6),
              onPressed: openCheckout,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(10)), child: Text('$cartCount', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      const SizedBox(width: 12),
                      const Text('Charge Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text('Rp $cartTotal', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget buildRekapView() {
    double totalOmset = AppDatabase.transactions.where((t) => !(t['voided'] ?? false)).fold(0, (sum, item) => sum + (item['total'] as double));
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
              const Text('Status Shift', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(),
              const Text('Shift Awal: 00.20'),
              const Text('Shift Akhir: Sedang Berlangsung', style: TextStyle(color: Colors.amber)),
              const SizedBox(height: 16),
              Text('Total Omset: Rp $totalOmset', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRiwayatView() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: AppDatabase.transactions.length,
      itemBuilder: (context, index) {
        var tx = AppDatabase.transactions[index];
        return Card(
          child: ListTile(
            title: Row(
              children: [
                Text(tx['id'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: tx['id']));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nomor Transaksi ${tx['id']} berhasil disalin!')));
                  },
                  child: const Icon(Icons.copy, size: 16, color: Colors.grey),
                ),
              ],
            ),
            subtitle: Text('Total: Rp ${tx['total']} • ${tx['method']} • ${tx['time']}'),
          ),
        );
      },
    );
  }

  Widget buildShiftView() {
    return const Center(child: Text('Shift Management Aktif'));
  }

  Widget buildPrinterView() {
    return const Center(child: Text('Setting Printer & Struk'));
  }

  Widget buildLogDeviceView() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: AppDatabase.connectedDevices.length,
      itemBuilder: (context, index) {
        var dev = AppDatabase.connectedDevices[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.devices, color: Colors.green),
            title: Text(dev['deviceName']),
            subtitle: Text('IP: ${dev['ip']}'),
            trailing: Chip(label: Text(dev['status']), backgroundColor: Colors.green.shade100),
          ),
        );
      },
    );
  }

  Widget buildKeyKasirView() {
    TextEditingController nameController = TextEditingController();
    TextEditingController branchController = TextEditingController();
    TextEditingController pinController = TextEditingController(text: "123456");

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Kasir', filled: true, fillColor: Colors.white)),
          const SizedBox(height: 10),
          TextField(controller: branchController, decoration: const InputDecoration(labelText: 'Nama Cabang', filled: true, fillColor: Colors.white)),
          const SizedBox(height: 10),
          TextField(controller: pinController, decoration: const InputDecoration(labelText: 'PIN Akses Kasir (6 Digit)', filled: true, fillColor: Colors.white)),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  AppDatabase.cashiers.add({'name': nameController.text, 'branch': branchController.text, 'pin': pinController.text});
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Key Kasir Berhasil Dibuat!')));
              }
            },
            child: const Text('Buat & Simpan Key Kasir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget buildSettingTokoView() {
    TextEditingController storeController = TextEditingController(text: AppDatabase.storeName);
    TextEditingController addressController = TextEditingController(text: AppDatabase.storeAddress);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(controller: storeController, decoration: const InputDecoration(labelText: 'Nama Toko Utama', filled: true, fillColor: Colors.white)),
          const SizedBox(height: 10),
          TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Alamat Toko', filled: true, fillColor: Colors.white)),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
            onPressed: () {
              setState(() {
                AppDatabase.storeName = storeController.text;
                AppDatabase.storeAddress = addressController.text;
              });
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengaturan Toko Disimpan!')));
            },
            child: const Text('Simpan Perubahan Toko', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget buildSettingProdukView() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: AppDatabase.products.length,
      itemBuilder: (context, index) {
        var p = AppDatabase.products[index];
        return Card(
          child: ListTile(
            title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Stock ${p['stock']} • HPP: Rp ${p['hpp']} • Harga: Rp ${p['price']}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () { setState(() { AppDatabase.products.removeAt(index); }); },
            ),
          ),
        );
      },
    );
  }

  Widget buildAdminOtpView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.vpn_key, size: 48, color: Color(0xFF1E3A8A)),
                const SizedBox(height: 16),
                const Text('OTP Validasi Admin Aktif', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(AppDatabase.activeOtp, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
                  onPressed: () {
                    setState(() {
                      int randomOtp = 100000 + DateTime.now().millisecond * 89;
                      AppDatabase.activeOtp = randomOtp.toString();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP Baru Berhasil Digenerate!')));
                  },
                  child: const Text('Generate OTP Baru', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAdminRekapView() {
    if (AppDatabase.transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('Belum ada data transaksi dari kasir.', style: TextStyle(color: Colors.grey))),
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
                    Text(kasirName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() { AppDatabase.transactions.removeWhere((t) => t['kasir'] == kasirName); });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data kasir $kasirName berhasil dihapus!')));
                      },
                    ),
                  ],
                ),
                const Divider(),
                Text('Total Transaksi: ${data['count']}'),
                Text('Total Omset: Rp ${data['omset']}'),
                Text('Keuntungan: Rp ${data['profit']}', style: const TextStyle(color: Colors.green)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
