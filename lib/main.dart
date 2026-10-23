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
        primaryColor: const Color(0xFF1E3A8A),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const RoleSelectPage(),
    );
  }
}

class AppDatabase {
  static String storeName = "RBE POS Utama";
  static String storeAddress = "Jl. Raya Utama No. 45, Surabaya";
  
  static List<String> categories = ['All item', 'Discounts', 'Food', 'Beverage'];
  
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
    {'deviceName': 'Tablet Kasir Utama (Budi Santoso)', 'ip': '192.168.1.15', 'status': 'Online', 'kasir': 'Budi Santoso'}
  ];

  static List<Map<String, dynamic>> shiftHistory = [
    {'date': '2026-10-23', 'kasir': 'Budi Santoso', 'shift': 'Pagi (08:00 - 16:00)', 'omset': 42000, 'status': 'Selesai'}
  ];

  static bool isShiftActive = false;
  static String shiftStartTime = "-";
  static double kasAwal = 0;
  
  // Variabel untuk menyimpan OTP Void yang digenerate Admin
  static String currentVoidOtp = "";
}

// ==========================================
// 1. HALAMAN PILIH ROLE
// ==========================================
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

// ==========================================
// 2. HALAMAN LOGIN PIN
// ==========================================
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
      bool exists = AppDatabase.connectedDevices.any((d) => d['kasir'] == 'Budi Santoso');
      if (!exists) {
        AppDatabase.connectedDevices.add({
          'deviceName': 'Mobile Kasir (Budi Santoso)',
          'ip': '192.168.1.20',
          'status': 'Online',
          'kasir': 'Budi Santoso'
        });
      }
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

// ==========================================
// 3. DASHBOARD UTAMA
// ==========================================
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

  void customPriceDialog(Map<String, dynamic> p) {
    TextEditingController priceController = TextEditingController(text: p['price'].toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Custom Harga: ${p['name']}'),
        content: TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Harga Baru (Rp)', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
            onPressed: () {
              double? newP = double.tryParse(priceController.text);
              if (newP != null) {
                setState(() {
                  p['price'] = newP;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harga berhasil diubah!')));
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
            List<String> methods = ['Cash', 'QRIS All Bank', 'OVO', 'GoPay', 'DANA', 'ShopeePay', 'EDC / Kartu Bank', 'GrabFood', 'GoFood', 'ShopeeFood'];
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
                        Text('Total: Rp $cartTotal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const Divider(),
                    const Text('PILIH METODE PEMBAYARAN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                      itemCount: methods.length,
                      itemBuilder: (context, index) {
                        String m = methods[index];
                        bool isSelected = selectedMethod == m;
                        return InkWell(
                          onTap: () { setModalState(() { selectedMethod = m; }); },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade300),
                            ),
                            child: Text(m, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        );
                      },
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
    String todayDate = DateTime.now().toString().substring(0, 10);

    Map<String, dynamic> newTx = {
      'id': trxId,
      'date': todayDate,
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
    
    var shiftIndex = AppDatabase.shiftHistory.indexWhere((s) => s['kasir'] == 'Budi Santoso' && s['date'] == todayDate);
    if (shiftIndex >= 0) {
      AppDatabase.shiftHistory[shiftIndex]['omset'] += total;
    } else {
      AppDatabase.shiftHistory.add({'date': todayDate, 'kasir': 'Budi Santoso', 'shift': 'Aktif', 'omset': total, 'status': 'Aktif'});
    }

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
              Text('ID: $trxId • Metode: $method', style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
        title: Text(
          currentView == 'pos' ? 'Point of Sale' :
          currentView == 'rekap' ? 'Detail Rekapitulasi' :
          currentView == 'riwayat' ? 'Riwayat Penjualan' :
          currentView == 'shift' ? 'Shift Management' :
          currentView == 'printer' ? 'Setting Printer & Struk' :
          currentView == 'logdevice' ? 'Log Device Terhubung' :
          currentView == 'keykasir' ? 'Generate Key Kasir' :
          currentView == 'settingtoko' ? 'Setting Toko' :
          currentView == 'settingproduk' ? 'Setting Produk & Harga' :
          currentView == 'settingkategori' ? 'Setting Kategori' :
          currentView == 'admintransaksi' ? 'Laporan Transaksi Admin' : 'Laporan Omset Per Tanggal',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
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
                  Text(AppDatabase.isShiftActive ? 'Shift: Aktif' : 'Shift: Tidak Aktif', style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 11)),
                ],
              ),
            ),
            ListTile(leading: const Icon(Icons.point_of_sale), title: const Text('Point of Sale'), onTap: () { setState(() { currentView = 'pos'; searchQuery = ''; }); Navigator.pop(context); }),
            if (widget.isAdmin) ...[
              ListTile(leading: const Icon(Icons.devices), title: const Text('Log Device'), onTap: () { setState(() => currentView = 'logdevice'); Navigator.pop(context); }),
              ListTile(leading: const Icon(Icons.vpn_key), title: const Text('Key Kasir'), onTap: () { setState(() => currentView = 'keykasir'); Navigator.pop(context); }),
              ListTile(leading: const Icon(Icons.receipt_long), title: const Text('Laporan Transaksi & Void'), onTap: () { setState(() { currentView = 'admintransaksi'; searchQuery = ''; }); Navigator.pop(context); }),
              ListTile(leading: const Icon(Icons.date_range), title: const Text('Laporan Omset Per Tanggal'), onTap: () { setState(() => currentView = 'adminrekap'); Navigator.pop(context); }),
              ListTile(leading: const Icon(Icons.storefront), title: const Text('Setting Toko'), onTap: () { setState(() => currentView = 'settingtoko'); Navigator.pop(context); }),
              ListTile(leading: const Icon(Icons.category), title: const Text('Setting Kategori'), onTap: () { setState(() => currentView = 'settingkategori'); Navigator.pop(context); }),
              ListTile(leading: const Icon(Icons.inventory_2), title: const Text('Setting Produk'), onTap: () { setState(() => currentView = 'settingproduk'); Navigator.pop(context); }),
            ] else ...[
              ListTile(leading: const Icon(Icons.pie_chart), title: const Text('Rekapitulasi'), onTap: () { setState(() => currentView = 'rekap'); Navigator.pop(context); }),
              ListTile(leading: const Icon(Icons.history), title: const Text('Riwayat Penjualan'), onTap: () { setState(() => currentView = 'riwayat'); Navigator.pop(context); }),
              ListTile(leading: const Icon(Icons.schedule), title: const Text('Shift Management'), onTap: () { setState(() => currentView = 'shift'); Navigator.pop(context); }),
              ListTile(leading: const Icon(Icons.print), title: const Text('Setting Printer & Struk'), onTap: () { setState(() => currentView = 'printer'); Navigator.pop(context); }),
            ],
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Keluar / Ganti Akun', style: TextStyle(color: Colors.red)),
              onTap: () {
                AppDatabase.connectedDevices.removeWhere((d) => d['kasir'] == 'Budi Santoso');
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RoleSelectPage()));
              },
            ),
          ],
        ),
      ),
      body: currentView == 'pos' ? buildPosView() :
            currentView == 'rekap' ? buildRekapView() :
            currentView == 'riwayat' ? buildRiwayatView() :
            currentView == 'shift' ? buildShiftView() :
            currentView == 'printer' ? buildPrinterView() :
            currentView == 'logdevice' ? buildLogDeviceView() :
            currentView == 'keykasir' ? buildKeyKasirView() :
            currentView == 'settingtoko' ? buildSettingTokoView() :
            currentView == 'settingkategori' ? buildSettingKategoriView() :
            currentView == 'settingproduk' ? buildSettingProdukView() :
            currentView == 'admintransaksi' ? buildAdminTransaksiView() : buildAdminRekapView(),
    );
  }

  // ============================
  // WIDGET BUILDERS
  // ============================

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
                      children: AppDatabase.categories.map((cat) {
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
                      subtitle: Text('Stock ${p['stock']} • Kategori: ${p['category']}', style: const TextStyle(color: Colors.grey)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Rp ${p['price']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                          const SizedBox(width: 8),
                          IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.grey), onPressed: () => customPriceDialog(p)),
                        ],
                      ),
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
    double totalOmset = AppDatabase.transactions.where((t) => t['kasir'] == 'Budi Santoso' && !(t['voided'] ?? false)).fold(0, (sum, item) => sum + (item['total'] as double));
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Status Shift Kasir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(),
              Text('Shift Awal: ${AppDatabase.shiftStartTime}'),
              Text(AppDatabase.isShiftActive ? 'Shift Akhir: Sedang Berlangsung' : 'Shift Akhir: Selesai', style: TextStyle(color: AppDatabase.isShiftActive ? Colors.amber.shade700 : Colors.green)),
              const SizedBox(height: 8),
              Text('Kas Awal: Rp ${AppDatabase.kasAwal}'),
              const SizedBox(height: 16),
              Text('Total Omset Shift: Rp $totalOmset', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2563EB))),
            ],
          ),
        ),
      ),
    );
  }

  // RIWAYAT KASIR (DENGAN KLIK DETAIL, COPY TRX & VOID OTP)
  Widget buildRiwayatView() {
    var myTx = AppDatabase.transactions.where((t) => t['kasir'] == 'Budi Santoso').toList();
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: myTx.length,
      itemBuilder: (context, index) {
        var tx = myTx[index];
        bool isVoid = tx['voided'] ?? false;
        return Card(
          elevation: 0, color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            title: Text(tx['id'], style: TextStyle(fontWeight: FontWeight.bold, decoration: isVoid ? TextDecoration.lineThrough : null, color: isVoid ? Colors.red : Colors.black87)),
            subtitle: Text('Total: Rp ${tx['total']} • ${isVoid ? "VOIDED" : "Sukses"}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  TextEditingController otpController = TextEditingController();
                  return AlertDialog(
                    title: const Text('Detail Transaksi'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tx['id'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: tx['id']));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID Transaksi disalin!')));
                              },
                            ),
                          ],
                        ),
                        Text('Total: Rp ${tx['total']}'),
                        Text('Metode: ${tx['method']}'),
                        const SizedBox(height: 16),
                        if (!isVoid) ...[
                          const Text('Void Pesanan (Butuh OTP Admin):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: otpController,
                            decoration: const InputDecoration(hintText: 'Masukkan OTP', border: OutlineInputBorder(), isDense: true),
                            keyboardType: TextInputType.number,
                          ),
                        ] else const Text('STATUS: VOIDED', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                      ],
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
                      if (!isVoid)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () {
                            if (otpController.text == AppDatabase.currentVoidOtp && otpController.text.isNotEmpty) {
                              setState(() { tx['voided'] = true; AppDatabase.currentVoidOtp = ""; });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaksi berhasil di-void!')));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP Salah!')));
                            }
                          },
                          child: const Text('Void Transaksi', style: TextStyle(color: Colors.white)),
                        ),
                    ],
                  );
                }
              );
            },
          ),
        );
      },
    );
  }

  Widget buildShiftView() {
    TextEditingController kasAwalController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.white, elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppDatabase.isShiftActive ? 'Shift Sedang Aktif' : 'Shift Belum Dimulai', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppDatabase.isShiftActive ? Colors.green : Colors.red)),
                  const SizedBox(height: 12),
                  if (!AppDatabase.isShiftActive) ...[
                    TextField(controller: kasAwalController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Masukkan Modal Kas Awal (Rp)', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 48)),
                      onPressed: () {
                        setState(() {
                          AppDatabase.isShiftActive = true;
                          AppDatabase.shiftStartTime = DateTime.now().toString().substring(11, 16);
                          AppDatabase.kasAwal = double.tryParse(kasAwalController.text) ?? 0;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shift Berhasil Dimulai!')));
                      },
                      child: const Text('Mulai Shift', style: TextStyle(color: Colors.white)),
                    ),
                  ] else ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(double.infinity, 48)),
                      onPressed: () {
                        setState(() {
                          AppDatabase.isShiftActive = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shift Berhasil Diakhiri!')));
                      },
                      child: const Text('Akhiri Shift', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Riwayat Shift & Omset Harian', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: AppDatabase.shiftHistory.length,
              itemBuilder: (context, index) {
                var s = AppDatabase.shiftHistory[index];
                return Card(
                  color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text('Tanggal: ${s['date']} (${s['shift']})'),
                    subtitle: Text('Kasir: ${s['kasir']}'),
                    trailing: Text('Rp ${s['omset']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // SETTING PRINTER
  Widget buildPrinterView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pengaturan Struk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Card(
            color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: const Text('Tampilkan Logo di Struk'),
              trailing: Switch(value: true, activeColor: const Color(0xFF1E3A8A), onChanged: (val) {}),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Printer Bluetooth Terhubung', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Card(
            color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.green.shade200), borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.print, color: Color(0xFF1E3A8A)),
              title: const Text('RPP02N Printer (Aktif)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Mac: 00:11:22:33:44:55'),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mencetak Test Print...')));
                },
                child: const Text('Test Print', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLogDeviceView() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: AppDatabase.connectedDevices.length,
      itemBuilder: (context, index) {
        var dev = AppDatabase.connectedDevices[index];
        return Card(
          color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.devices, color: Colors.green),
            title: Text(dev['deviceName'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('IP: ${dev['ip']} • Kasir: ${dev['kasir']}'),
            trailing: IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              onPressed: () {
                setState(() { AppDatabase.connectedDevices.removeAt(index); });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perangkat berhasil dikeluarkan!')));
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildKeyKasirView() {
    TextEditingController nameController = TextEditingController();
    TextEditingController branchController = TextEditingController();
    TextEditingController pinController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Kasir', border: OutlineInputBorder(), isDense: true, filled: true, fillColor: Colors.white)),
          const SizedBox(height: 8),
          TextField(controller: branchController, decoration: const InputDecoration(labelText: 'Nama Cabang', border: OutlineInputBorder(), isDense: true, filled: true, fillColor: Colors.white)),
          const SizedBox(height: 8),
          TextField(controller: pinController, keyboardType: TextInputType.number, maxLength: 6, decoration: const InputDecoration(labelText: 'PIN Akses Kasir (6 Digit)', border: OutlineInputBorder(), isDense: true, filled: true, fillColor: Colors.white, counterText: '')),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), minimumSize: const Size(double.infinity, 48)),
            onPressed: () {
              if (nameController.text.isNotEmpty && pinController.text.length == 6) {
                setState(() { AppDatabase.cashiers.add({'name': nameController.text, 'branch': branchController.text, 'pin': pinController.text}); });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Key Kasir Berhasil Disimpan!')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi data dan PIN harus 6 digit!'), backgroundColor: Colors.red));
              }
            },
            child: const Text('Buat & Simpan Key Kasir', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 16),
          const Text('DAFTAR KEY KASIR AKTIF', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: AppDatabase.cashiers.length,
              itemBuilder: (context, index) {
                var c = AppDatabase.cashiers[index];
                return Card(
                  color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(c['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${c['branch']} • PIN: ${c['pin']}'),
                    trailing: const Chip(label: Text('Aktif', style: TextStyle(color: Colors.green)), backgroundColor: Color(0xFFD1FAE5), side: BorderSide.none),
                  ),
                );
              },
            ),
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
          TextField(controller: storeController, decoration: const InputDecoration(labelText: 'Nama Toko Utama', border: OutlineInputBorder(), isDense: true, filled: true, fillColor: Colors.white)),
          const SizedBox(height: 12),
          TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Alamat Toko', border: OutlineInputBorder(), isDense: true, filled: true, fillColor: Colors.white)),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), minimumSize: const Size(double.infinity, 48)),
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

  Widget buildSettingKategoriView() {
    TextEditingController catController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(controller: catController, decoration: const InputDecoration(labelText: 'Nama Kategori Baru', border: OutlineInputBorder(), isDense: true, filled: true, fillColor: Colors.white)),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), minimumSize: const Size(double.infinity, 48)),
            onPressed: () {
              if (catController.text.isNotEmpty) {
                setState(() { AppDatabase.categories.add(catController.text); });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kategori Ditambahkan!')));
              }
            },
            child: const Text('Tambah Kategori', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 16),
          const Text('Daftar Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView.builder(
              itemCount: AppDatabase.categories.length,
              itemBuilder: (context, index) {
                return Card(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: ListTile(title: Text(AppDatabase.categories[index])));
              },
            ),
          ),
        ],
      ),
    );
  }

  // SETTING PRODUK (TAMBAH, HAPUS, FOTO PLACEHOLDER)
  Widget buildSettingProdukView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Buka form tambah produk & upload foto')));
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Tambah Produk Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: AppDatabase.products.length,
            itemBuilder: (context, index) {
              var p = AppDatabase.products[index];
              return Card(
                color: Colors.white, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                child: ListTile(
                  leading: Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300)
                    ),
                    child: const Icon(Icons.image, color: Colors.grey), // Placeholder Foto
                  ),
                  title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Kategori: ${p['category']} • Rp ${p['price']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() { AppDatabase.products.removeAt(index); });
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // LAPORAN ADMIN (CARI TRX & GENERATE OTP VOID KETIKA DIKLIK)
  Widget buildAdminTransaksiView() {
    var filteredTx = AppDatabase.transactions.where((t) => t['id'].toLowerCase().contains(searchQuery.toLowerCase())).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            onChanged: (val) => setState(() => searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Cari No Transaksi...', 
              prefixIcon: const Icon(Icons.search), 
              filled: true, fillColor: Colors.white, 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
            ),
          ),
        ),
        Expanded(
          child: filteredTx.isEmpty ? const Center(child: Text('Tidak ada transaksi.')) :
          ListView.builder(
            itemCount: filteredTx.length,
            itemBuilder: (context, index) {
              var tx = filteredTx[index];
              bool isVoid = tx['voided'] ?? false;
              return Card(
                color: Colors.white, elevation: 0,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                child: ListTile(
                  title: Text(tx['id'], style: TextStyle(fontWeight: FontWeight.bold, decoration: isVoid ? TextDecoration.lineThrough : null, color: isVoid ? Colors.red : Colors.black87)),
                  subtitle: Text('Kasir: ${tx['kasir']} • Rp ${tx['total']} • ${isVoid ? "VOIDED" : "Sukses"}'),
                  onTap: () {
                    if (!isVoid) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Kelola Transaksi'),
                          content: Text('Nomor Transaksi:\n${tx['id']}\n\nKlik tombol di bawah untuk membuat kode OTP Void.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                              onPressed: () {
                                setState(() {
                                  AppDatabase.currentVoidOtp = (100000 + DateTime.now().millisecond * 89).toString();
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('OTP Berhasil Dibuat: ${AppDatabase.currentVoidOtp}'),
                                    duration: const Duration(seconds: 10),
                                    action: SnackBarAction(label: 'Copy', textColor: Colors.white, onPressed: () {
                                      Clipboard.setData(ClipboardData(text: AppDatabase.currentVoidOtp));
                                    }),
                                  )
                                );
                              },
                              child: const Text('Generate OTP Void', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        )
                      );
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildAdminRekapView() {
    Map<String, double> dateOmset = {};
    for (var t in AppDatabase.transactions) {
      if (t['voided'] ?? false) continue;
      String date = t['date'] ?? '2026-10-23';
      dateOmset[date] = (dateOmset[date] ?? 0) + (t['total'] as double);
    }

    if (dateOmset.isEmpty) return const Center(child: Text('Belum ada data omset transaksi.'));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: dateOmset.entries.map((entry) {
        return Card(
          color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tanggal: ${entry.key}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3A8A))),
                const Divider(),
                Text('Total Omset: Rp ${entry.value}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
