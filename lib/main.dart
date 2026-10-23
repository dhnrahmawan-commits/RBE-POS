import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const RbePosApp());
}

// Fungsi Bantuan untuk Format Rupiah
String formatRp(num value) {
  String text = value.toStringAsFixed(0);
  String result = '';
  int count = 0;
  for (int i = text.length - 1; i >= 0; i--) {
    count++;
    result = text[i] + result;
    if (count % 3 == 0 && i != 0) {
      result = '.$result';
    }
  }
  return 'Rp $result';
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
  
  // Database Produk: Menyimpan harga Offline & Online
  static List<Map<String, dynamic>> products = [
    {'name': 'Nasi goreng kampung', 'category': 'Food', 'stock': 50, 'priceOffline': 21600, 'priceOnline': 27000, 'hpp': 15000},
    {'name': 'Nasi goreng teri', 'category': 'Food', 'stock': 50, 'priceOffline': 22000, 'priceOnline': 28000, 'hpp': 16000},
    {'name': 'Nasi goreng spesial', 'category': 'Food', 'stock': 50, 'priceOffline': 25000, 'priceOnline': 32000, 'hpp': 18000},
    {'name': 'Nasi goreng bakso', 'category': 'Food', 'stock': 50, 'priceOffline': 21000, 'priceOnline': 26000, 'hpp': 15000},
    {'name': 'Es Teh Manis', 'category': 'Beverage', 'stock': 100, 'priceOffline': 5000, 'priceOnline': 6500, 'hpp': 3000},
  ];

  static List<Map<String, dynamic>> cashiers = [
    {'name': 'Budi Santoso', 'branch': 'Cabang Pusat', 'pin': '123456'}
  ];

  static List<Map<String, dynamic>> connectedDevices = [];
  static List<Map<String, dynamic>> shiftHistory = [];

  static bool isShiftActive = false;
  static String currentShiftId = "";
  static String shiftStartTime = "-";
  static double kasAwal = 0;
  static String currentVoidOtp = "";
}

// ==========================================
// 1. HALAMAN PILIH ROLE & LOGIN
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
              Container(width: 96, height: 96, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)), child: const Center(child: Icon(Icons.store, size: 48, color: Color(0xFF1E3A8A)))),
              const SizedBox(height: 16),
              const Text('RBE POS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF1E3A8A), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(role: 'kasir'))),
                icon: const Icon(Icons.person), label: const Text('Login Kasir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Color(0xFF2563EB)), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(role: 'admin'))),
                icon: const Icon(Icons.admin_panel_settings), label: const Text('Login Device Utama (Admin)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 32),
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
      setState(() => pinInput += num);
      if (pinInput.length == 6) Future.delayed(const Duration(milliseconds: 300), validatePin);
    }
  }
  void clearPin() => setState(() => pinInput = "");

  void validatePin() {
    if (widget.role == 'admin' && pinInput == "999999") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainDashboard(isAdmin: true)));
    } else if (widget.role == 'kasir' && pinInput == "123456") {
      if (!AppDatabase.connectedDevices.any((d) => d['kasir'] == 'Budi Santoso')) {
        AppDatabase.connectedDevices.add({'deviceName': 'Mobile Kasir', 'ip': '192.168.1.20', 'kasir': 'Budi Santoso'});
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainDashboard(isAdmin: false)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN Salah!'), backgroundColor: Colors.red));
      clearPin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      body: SafeArea(
        child: Column(
          children: [
            Align(alignment: Alignment.topLeft, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RoleSelectPage())))),
            const Spacer(),
            const Icon(Icons.lock, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(widget.role == 'admin' ? 'PIN Admin' : 'PIN Kasir', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) => Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 16, height: 16, decoration: BoxDecoration(shape: BoxShape.circle, color: i < pinInput.length ? Colors.white : Colors.transparent, border: Border.all(color: Colors.white, width: 2)))),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: GridView.count(
                crossAxisCount: 3, shrinkWrap: true, childAspectRatio: 1.5,
                children: [
                  for (var i = 1; i <= 9; i++) TextButton(onPressed: () => pressPin('$i'), child: Text('$i', style: const TextStyle(fontSize: 24, color: Colors.white))),
                  TextButton(onPressed: clearPin, child: const Text('C', style: TextStyle(fontSize: 24, color: Colors.redAccent))),
                  TextButton(onPressed: () => pressPin('0'), child: const Text('0', style: TextStyle(fontSize: 24, color: Colors.white))),
                  TextButton(onPressed: () { if (pinInput.isNotEmpty) setState(() => pinInput = pinInput.substring(0, pinInput.length - 1)); }, child: const Icon(Icons.backspace, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. DASHBOARD UTAMA (KASIR & ADMIN)
// ==========================================
class MainDashboard extends StatefulWidget {
  final bool isAdmin;
  const MainDashboard({super.key, required this.isAdmin});
  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  String currentView = 'pos';
  String searchQuery = "";
  String selectedCategory = "All item";
  bool isOnlineOrder = false; // Toggle Offline/Online Kasir
  List<Map<String, dynamic>> cart = [];

  double get cartTotal => cart.fold(0, (sum, item) => sum + (item['price'] * item['qty']));
  int get cartCount => cart.fold(0, (sum, item) => sum + (item['qty'] as int));

  void addToCart(Map<String, dynamic> p) {
    if (!AppDatabase.isShiftActive && !widget.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mulai Shift terlebih dahulu!'), backgroundColor: Colors.red));
      return;
    }
    setState(() {
      double activePrice = isOnlineOrder ? p['priceOnline'] : p['priceOffline'];
      int index = cart.indexWhere((item) => item['name'] == p['name'] && item['price'] == activePrice);
      if (index >= 0) cart[index]['qty']++;
      else cart.add({'name': p['name'], 'price': activePrice, 'hpp': p['hpp'], 'qty': 1});
    });
  }

  void openCheckout() {
    String selectedMethod = "Cash";
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            List<String> methods = ['Cash', 'QRIS All Bank', 'GoPay', 'DANA', 'ShopeePay', 'EDC / Kartu Bank'];
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20, bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Total: ${formatRp(cartTotal)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ]),
                  const Divider(),
                  const Text('PILIH METODE PEMBAYARAN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                    itemCount: methods.length,
                    itemBuilder: (context, index) {
                      String m = methods[index];
                      bool isSelected = selectedMethod == m;
                      return InkWell(
                        onTap: () => setModalState(() => selectedMethod = m),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade300)),
                          child: Text(m, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    onPressed: () { Navigator.pop(context); processPaymentFinal(selectedMethod); },
                    child: Text('Konfirmasi ${formatRp(cartTotal)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void processPaymentFinal(String method) {
    String trxId = "TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";
    double totalHpp = cart.fold(0, (sum, item) => sum + (item['hpp'] * item['qty']));
    
    AppDatabase.transactions.add({
      'id': trxId,
      'shiftId': AppDatabase.currentShiftId,
      'date': DateTime.now().toString().substring(0, 10),
      'kasir': "Budi Santoso",
      'orderType': isOnlineOrder ? 'Online' : 'Offline',
      'items': List.from(cart),
      'total': cartTotal,
      'total_hpp': totalHpp,
      'profit': cartTotal - totalHpp,
      'method': method,
      'voided': false,
    });

    setState(() => cart.clear());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaksi Berhasil! ID: $trxId'), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentView == 'pos' ? 'Point of Sale' :
          currentView == 'rekap' ? 'Detail Rekapitulasi' :
          currentView == 'riwayat' ? 'Riwayat Transaksi Shift' :
          currentView == 'shift' ? 'Shift Management' :
          currentView == 'printer' ? 'Setting Printer' :
          currentView == 'logdevice' ? 'Log Device Terhubung' :
          currentView == 'keykasir' ? 'Kelola Key Kasir' :
          currentView == 'settingtoko' ? 'Setting Toko' :
          currentView == 'settingkategori' ? 'Setting Kategori' :
          currentView == 'settingproduk' ? 'Setting Produk & Harga' :
          currentView == 'admintransaksi' ? 'Laporan Transaksi (Admin)' :
          currentView == 'adminrekap' ? 'Laporan Omset (Admin)' : 'RBE POS',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      drawer: buildDrawer(),
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
            currentView == 'admintransaksi' ? buildAdminTransaksiView() : 
            currentView == 'adminrekap' ? buildAdminRekapView() : 
            const Center(child: Text('Halaman tidak ditemukan')),
    );
  }

  Widget buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1E3A8A)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
              const Icon(Icons.store, color: Colors.white, size: 36),
              const SizedBox(height: 8),
              Text(AppDatabase.storeName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(widget.isAdmin ? 'Admin Utama' : 'Kasir: Budi Santoso', style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 12)),
            ]),
          ),
          ListTile(leading: const Icon(Icons.point_of_sale), title: const Text('Point of Sale'), onTap: () { setState(() => currentView = 'pos'); Navigator.pop(context); }),
          if (widget.isAdmin) ...[
            ListTile(leading: const Icon(Icons.devices), title: const Text('Log Device'), onTap: () { setState(() => currentView = 'logdevice'); Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.vpn_key), title: const Text('Key Kasir'), onTap: () { setState(() => currentView = 'keykasir'); Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.receipt_long), title: const Text('Laporan Transaksi & Void'), onTap: () { setState(() => currentView = 'admintransaksi'); Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.bar_chart), title: const Text('Laporan Omset Detail'), onTap: () { setState(() => currentView = 'adminrekap'); Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.storefront), title: const Text('Setting Toko'), onTap: () { setState(() => currentView = 'settingtoko'); Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.category), title: const Text('Setting Kategori'), onTap: () { setState(() => currentView = 'settingkategori'); Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.inventory_2), title: const Text('Setting Produk & Harga'), onTap: () { setState(() => currentView = 'settingproduk'); Navigator.pop(context); }),
          ] else ...[
            ListTile(leading: const Icon(Icons.pie_chart), title: const Text('Detail Rekapitulasi'), onTap: () { setState(() => currentView = 'rekap'); Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.history), title: const Text('Riwayat Shift Ini'), onTap: () { setState(() => currentView = 'riwayat'); Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.schedule), title: const Text('Shift Management'), onTap: () { setState(() => currentView = 'shift'); Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.print), title: const Text('Setting Printer & Struk'), onTap: () { setState(() => currentView = 'printer'); Navigator.pop(context); }),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              AppDatabase.connectedDevices.removeWhere((d) => d['kasir'] == 'Budi Santoso');
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RoleSelectPage()));
            },
          ),
        ],
      ),
    );
  }

  // ============================
  // WIDGET KASIR & POS
  // ============================
  Widget buildPosView() {
    var filteredProducts = AppDatabase.products.where((p) => selectedCategory == 'All item' || p['category'] == selectedCategory).toList();
    return Stack(
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Jenis Order:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ToggleButtons(
                    isSelected: [!isOnlineOrder, isOnlineOrder],
                    onPressed: (index) => setState(() => isOnlineOrder = index == 1),
                    color: Colors.grey, selectedColor: Colors.white, fillColor: const Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(8), constraints: const BoxConstraints(minHeight: 36, minWidth: 80),
                    children: const [Text('Offline'), Text('Online (Ojol)')],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12), itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  var p = filteredProducts[index];
                  double displayPrice = isOnlineOrder ? p['priceOnline'] : p['priceOffline'];
                  return Card(
                    color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
                    child: ListTile(
                      title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Stok: ${p['stock']}'),
                      trailing: Text(formatRp(displayPrice), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: openCheckout,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$cartCount Item', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('Bayar ${formatRp(cartTotal)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ============================
  // DETAIL REKAPITULASI KASIR
  // ============================
  Widget buildRekapView() {
    var shiftTx = AppDatabase.transactions.where((t) => t['shiftId'] == AppDatabase.currentShiftId && t['voided'] == false).toList();
    double totalOmset = shiftTx.fold(0, (sum, tx) => sum + tx['total']);
    
    // Group Metode Bayar
    Map<String, double> payMap = {};
    // Group Menu Terjual
    Map<String, int> itemMap = {};

    for (var tx in shiftTx) {
      payMap[tx['method']] = (payMap[tx['method']] ?? 0) + tx['total'];
      for (var item in tx['items']) {
        itemMap[item['name']] = (itemMap[item['name']] ?? 0) + (item['qty'] as int);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Status Shift Kasir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(),
                Text('Shift Awal: ${AppDatabase.shiftStartTime}'),
                Text(AppDatabase.isShiftActive ? 'Shift Akhir: Sedang Berlangsung' : 'Shift Akhir: Selesai', style: TextStyle(color: AppDatabase.isShiftActive ? Colors.amber.shade700 : Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Kas Awal: ${formatRp(AppDatabase.kasAwal)}'),
                const SizedBox(height: 12),
                Text('Total Omset Shift: ${formatRp(totalOmset)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E3A8A))),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Detail Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
                const Divider(),
                if (payMap.isEmpty) const Text('Belum ada transaksi', style: TextStyle(color: Colors.grey)),
                ...payMap.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(e.key), Text(formatRp(e.value), style: const TextStyle(fontWeight: FontWeight.bold))]),
                )),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Menu Terjual', style: TextStyle(fontWeight: FontWeight.bold)),
                const Divider(),
                if (itemMap.isEmpty) const Text('Belum ada item terjual', style: TextStyle(color: Colors.grey)),
                ...itemMap.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(e.key), Text('${e.value}x', style: const TextStyle(fontWeight: FontWeight.bold))]),
                )),
              ]),
            ),
          )
        ],
      ),
    );
  }

  // ============================
  // RIWAYAT TRANSAKSI KASIR (VOID)
  // ============================
  Widget buildRiwayatView() {
    var shiftTx = AppDatabase.transactions.where((t) => t['shiftId'] == AppDatabase.currentShiftId).toList();
    return ListView.builder(
      padding: const EdgeInsets.all(12), itemCount: shiftTx.length,
      itemBuilder: (context, index) {
        var tx = shiftTx[index];
        bool isVoid = tx['voided'];
        return Card(
          color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(tx['id'], style: TextStyle(fontWeight: FontWeight.bold, decoration: isVoid ? TextDecoration.lineThrough : null, color: isVoid ? Colors.red : Colors.black87)),
            subtitle: Text('${formatRp(tx['total'])} • ${tx['method']} • ${tx['orderType']}'),
            trailing: isVoid ? const Text('VOID', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)) : const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              if (isVoid) return;
              TextEditingController otpCtrl = TextEditingController();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Detail & Void'),
                  content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('ID: ${tx['id']}'), Text('Total: ${formatRp(tx['total'])}'), const SizedBox(height: 16),
                    const Text('Void Pesanan (Butuh OTP Admin):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    TextField(controller: otpCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Masukkan OTP', isDense: true)),
                  ]),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        if (otpCtrl.text == AppDatabase.currentVoidOtp && otpCtrl.text.isNotEmpty) {
                          setState(() { tx['voided'] = true; AppDatabase.currentVoidOtp = ""; });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaksi di-void!')));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP Salah!')));
                        }
                      },
                      child: const Text('Void Transaksi', style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ============================
  // SHIFT MANAGEMENT (SIMPAN OTOMATIS)
  // ============================
  Widget buildShiftView() {
    TextEditingController kasCtrl = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Card(
          color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              if (!AppDatabase.isShiftActive) ...[
                const Text('Mulai Shift Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                TextField(controller: kasCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Modal Kas Awal (Rp)', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 48)),
                  onPressed: () {
                    setState(() {
                      AppDatabase.isShiftActive = true;
                      AppDatabase.currentShiftId = DateTime.now().millisecondsSinceEpoch.toString();
                      AppDatabase.shiftStartTime = DateTime.now().toString().substring(11, 16);
                      AppDatabase.kasAwal = double.tryParse(kasCtrl.text) ?? 0;
                    });
                  }, child: const Text('Mulai Shift', style: TextStyle(color: Colors.white)),
                ),
              ] else ...[
                const Text('Shift Sedang Berlangsung', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(double.infinity, 48)),
                  onPressed: () {
                    var shiftTx = AppDatabase.transactions.where((t) => t['shiftId'] == AppDatabase.currentShiftId && t['voided'] == false).toList();
                    double totalOmset = shiftTx.fold(0, (s, t) => s + t['total']);
                    
                    setState(() {
                      AppDatabase.shiftHistory.insert(0, {
                        'date': DateTime.now().toString().substring(0, 10),
                        'kasir': 'Budi Santoso',
                        'shift': '${AppDatabase.shiftStartTime} - ${DateTime.now().toString().substring(11, 16)}',
                        'omset': totalOmset,
                        'trxCount': shiftTx.length
                      });
                      AppDatabase.isShiftActive = false;
                      AppDatabase.currentShiftId = "";
                    });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shift Berhasil Diakhiri. Data disimpan.')));
                  }, child: const Text('Akhiri Shift & Simpan Laporan', style: TextStyle(color: Colors.white)),
                ),
              ]
            ]),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Riwayat Shift Sebelumnya', style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: ListView.builder(
            itemCount: AppDatabase.shiftHistory.length,
            itemBuilder: (context, index) {
              var s = AppDatabase.shiftHistory[index];
              return Card(
                color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(s['date']), subtitle: Text('${s['shift']} • ${s['trxCount']} Trx'),
                  trailing: Text(formatRp(s['omset']), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ),
              );
            },
          ),
        )
      ]),
    );
  }

  // ============================
  // PENGATURAN KASIR / UMUM (PRINTER, LOG, TOKO, KATEGORI)
  // ============================
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
            child: ListTile(title: const Text('Tampilkan Logo di Struk'), trailing: Switch(value: true, activeColor: const Color(0xFF1E3A8A), onChanged: (val) {})),
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
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mencetak Test Print...'))),
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
      padding: const EdgeInsets.all(12), itemCount: AppDatabase.connectedDevices.length,
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
                setState(() => AppDatabase.connectedDevices.removeAt(index));
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
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Kasir', border: OutlineInputBorder(), isDense: true, filled: true, fillColor: Colors.white)), const SizedBox(height: 8),
          TextField(controller: branchController, decoration: const InputDecoration(labelText: 'Nama Cabang', border: OutlineInputBorder(), isDense: true, filled: true, fillColor: Colors.white)), const SizedBox(height: 8),
          TextField(controller: pinController, keyboardType: TextInputType.number, maxLength: 6, decoration: const InputDecoration(labelText: 'PIN Akses Kasir (6 Digit)', border: OutlineInputBorder(), isDense: true, filled: true, fillColor: Colors.white, counterText: '')), const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), minimumSize: const Size(double.infinity, 48)),
            onPressed: () {
              if (nameController.text.isNotEmpty && pinController.text.length == 6) {
                setState(() => AppDatabase.cashiers.add({'name': nameController.text, 'branch': branchController.text, 'pin': pinController.text}));
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
          TextField(controller: storeController, decoration: const InputDecoration(labelText: 'Nama Toko Utama', border: OutlineInputBorder(), isDense: true, filled: true, fillColor: Colors.white)), const SizedBox(height: 12),
          TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Alamat Toko', border: OutlineInputBorder(), isDense: true, filled: true, fillColor: Colors.white)), const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), minimumSize: const Size(double.infinity, 48)),
            onPressed: () {
              setState(() { AppDatabase.storeName = storeController.text; AppDatabase.storeAddress = addressController.text; });
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
          TextField(controller: catController, decoration: const InputDecoration(labelText: 'Nama Kategori Baru', border: OutlineInputBorder(), isDense: true, filled: true, fillColor: Colors.white)), const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), minimumSize: const Size(double.infinity, 48)),
            onPressed: () {
              if (catController.text.isNotEmpty) {
                setState(() => AppDatabase.categories.add(catController.text));
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

  // ============================
  // FITUR ADMIN: TAMBAH PRODUK
  // ============================
  Widget buildSettingProdukView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), minimumSize: const Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              TextEditingController nameC = TextEditingController();
              TextEditingController offC = TextEditingController();
              TextEditingController onC = TextEditingController();
              TextEditingController hppC = TextEditingController();
              showModalBottomSheet(
                context: context, isScrollControlled: true,
                builder: (context) => Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Tambah Produk Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Nama Produk', border: OutlineInputBorder(), isDense: true)), const SizedBox(height: 8),
                    TextField(controller: hppC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'HPP (Modal)', border: OutlineInputBorder(), isDense: true)), const SizedBox(height: 8),
                    TextField(controller: offC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga Offline (Dine In)', border: OutlineInputBorder(), isDense: true)), const SizedBox(height: 8),
                    TextField(controller: onC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga Online (Ojol)', border: OutlineInputBorder(), isDense: true)), const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), minimumSize: const Size(double.infinity, 48)),
                      onPressed: () {
                        setState(() {
                          AppDatabase.products.add({
                            'name': nameC.text, 'category': 'Food', 'stock': 100,
                            'priceOffline': double.tryParse(offC.text) ?? 0, 'priceOnline': double.tryParse(onC.text) ?? 0, 'hpp': double.tryParse(hppC.text) ?? 0
                          });
                        });
                        Navigator.pop(context);
                      }, child: const Text('Simpan Produk', style: TextStyle(color: Colors.white)),
                    ), const SizedBox(height: 16),
                  ]),
                )
              );
            }, icon: const Icon(Icons.add, color: Colors.white), label: const Text('Tambah Produk Baru', style: TextStyle(color: Colors.white)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: AppDatabase.products.length,
            itemBuilder: (context, index) {
              var p = AppDatabase.products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Offline: ${formatRp(p['priceOffline'])} | Online: ${formatRp(p['priceOnline'])}'),
                  trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => AppDatabase.products.removeAt(index))),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  // ============================
  // FITUR ADMIN: KELOLA TRX & OTP VOID
  // ============================
  Widget buildAdminTransaksiView() {
    var filteredTx = AppDatabase.transactions.reversed.toList();
    return Column(
      children: [
        if (AppDatabase.currentVoidOtp.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12), color: Colors.amber.shade100, width: double.infinity,
            child: Text('KODE OTP VOID AKTIF: ${AppDatabase.currentVoidOtp}\n(Berikan ke kasir)', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredTx.length,
            itemBuilder: (context, index) {
              var tx = filteredTx[index];
              bool isVoid = tx['voided'];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(tx['id'], style: TextStyle(fontWeight: FontWeight.bold, decoration: isVoid ? TextDecoration.lineThrough : null)),
                  subtitle: Text('${formatRp(tx['total'])} • Kasir: ${tx['kasir']}'),
                  trailing: isVoid ? const Text('VOIDED', style: TextStyle(color: Colors.red)) : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    onPressed: () {
                      setState(() { AppDatabase.currentVoidOtp = (100000 + DateTime.now().millisecond * 89).toString(); });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP Void Berhasil Dibuat!')));
                    }, child: const Text('Buat OTP Void', style: TextStyle(color: Colors.black, fontSize: 12)),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  // ============================
  // FITUR ADMIN: LAPORAN DETAIL OMSET
  // ============================
  Widget buildAdminRekapView() {
    Map<String, Map<String, double>> dateData = {};
    for (var tx in AppDatabase.transactions) {
      if (tx['voided']) continue;
      String date = tx['date'];
      if (!dateData.containsKey(date)) dateData[date] = {'omset': 0, 'hpp': 0, 'profit': 0};
      dateData[date]!['omset'] = dateData[date]!['omset']! + tx['total'];
      dateData[date]!['hpp'] = dateData[date]!['hpp']! + tx['total_hpp'];
      dateData[date]!['profit'] = dateData[date]!['profit']! + tx['profit'];
    }

    if (dateData.isEmpty) return const Center(child: Text('Belum ada transaksi.'));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: dateData.entries.map((e) {
        return Card(
          color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            title: Text('Tanggal: ${e.key}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Omset: ${formatRp(e.value['omset'] ?? 0)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total Omset Kotor'), Text(formatRp(e.value['omset'] ?? 0))]),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total Modal (HPP)', style: TextStyle(color: Colors.red)), Text('- ${formatRp(e.value['hpp'] ?? 0)}', style: const TextStyle(color: Colors.red))]),
                    const Divider(),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Laba Bersih (Profit)', style: TextStyle(fontWeight: FontWeight.bold)), Text(formatRp(e.value['profit'] ?? 0), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))]),
                  ],
                ),
              )
            ],
          ),
        );
      }).toList(),
    );
  }
}
