import 'package:flutter/material.dart';

void main() {
  runApp(const RbePosApp());
}

class RbePosApp extends StatefulWidget {
  const RbePosApp({super.key});

  @override
  State<RbePosApp> createState() => _RbePosAppState();
}

class _RbePosAppState extends State<RbePosApp> {
  // State untuk mengatur mode terang / gelap
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RBE-POS',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey.shade100,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: KasirHomePage(
        isDarkMode: _isDarkMode,
        onThemeChanged: (val) {
          setState(() {
            _isDarkMode = val;
          });
        },
      ),
    );
  }
}

// Model Data Transaksi Offline-First
class TransactionItem {
  final String productName;
  final int price;
  int qty;

  TransactionItem({required this.productName, required this.price, required this.qty});
}

class KasirHomePage extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const KasirHomePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<KasirHomePage> createState() => _KasirHomePageState();
}

class _KasirHomePageState extends State<KasirHomePage> {
  // Daftar Produk Toko
  final List<Map<String, dynamic>> products = [
    {'name': 'Nasi Goreng Kampung', 'price': 21600, 'stock': 50},
    {'name': 'Nasi Goreng Spesial', 'price': 25000, 'stock': 50},
    {'name': 'Es Teh Manis', 'price': 5000, 'stock': 50},
    {'name': 'Kopi Susu', 'price': 15000, 'stock': 30},
  ];

  // Keranjang Belanja Kasir (Penyimpanan Lokal Sementara)
  final List<TransactionItem> cart = [];
  
  // Riwayat Transaksi Offline (Disimpan di HP sebelum sinkron ke Admin)
  final List<Map<String, dynamic>> localOfflineTransactions = [];

  double get totalBelanja {
    return cart.fold(0, (sum, item) => sum + (item.price * item.qty).toDouble());
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      int index = cart.indexWhere((item) => item.productName == product['name']);
      if (index >= 0) {
        cart[index].qty++;
      } else {
        cart.add(TransactionItem(
          productName: product['name'],
          price: product['price'],
          qty: 1,
        ));
      }
    });
  }

  // Proses Pembayaran (Offline-First: Simpan lokal dulu, siap disinkronkan ke admin)
  void _processPayment() {
    if (cart.isEmpty) return;

    setState(() {
      for (var item in cart) {
        localOfflineTransactions.add({
          'product': item.productName,
          'qty': item.qty,
          'total': item.price * item.qty,
          'time': DateTime.now().toString(),
          'synced': false, // Status belum sinkron ke admin pusat
        });
      }
      cart.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaksi Berhasil Disimpan (Offline Mode)!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Fungsi Dialog PIN Admin
  void _showAdminPinDialog(BuildContext context) {
    TextEditingController pinController = TextEditingController();
    const String correctAdminPin = "123456"; // PIN Admin Utama

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('PIN Admin Toko'),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            decoration: const InputDecoration(
              hintText: 'Masukkan 6 digit PIN',
              counterText: '',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (pinController.text == correctAdminPin) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PIN Benar! Membuka Menu Admin...'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PIN Salah! Akses Ditolak.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Masuk'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RBE POS - Kasir'),
        elevation: 0,
      ),
      // --- MENU GARIS TIGA (DRAWER) TANPA BUG ABU-ABU ---
      drawer: Drawer(
        backgroundColor: Theme.of(context).cardColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text("RBE POS Utama"),
              accountEmail: const Text("Kasir: Budi Santoso (Cabang Pusat)"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.store, color: Colors.blue, size: 32),
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade800,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale),
              title: const Text('Point of Sale'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Menu Admin / PIN'),
              onTap: () {
                Navigator.pop(context);
                _showAdminPinDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Laporan Omset Lokal'),
              onTap: () {
                Navigator.pop(context);
                // Tampilkan jumlah transaksi offline tersimpan
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Laporan Transaksi Lokal'),
                    content: Text(localOfflineTransactions.isEmpty
                        ? 'Belum ada data transaksi dari kasir.'
                        : 'Total ${localOfflineTransactions.length} transaksi tersimpan secara offline.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(),
            // SWITCH MODE TERANG / GELAP
            SwitchListTile(
              secondary: Icon(
                widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
              title: const Text('Mode Gelap'),
              value: widget.isDarkMode,
              onChanged: widget.onThemeChanged,
            ),
          ],
        ),
      ),
      // --- TAMPILAN UTAMA KASIR ---
      body: Row(
        children: [
          // Bagian Kiri: Daftar Produk
          Expanded(
            flex: 3,
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    title: Text(
                      product['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Rp ${product['price']} | Stok: ${product['stock']}'),
                    trailing: ElevatedButton(
                      onPressed: () => _addToCart(product),
                      child: const Text('Tambah'),
                    ),
                  ),
                );
              },
            ),
          ),
          const VerticalDivider(width: 1),
          // Bagian Kanan: Keranjang & Pembayaran
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.blue.withOpacity(0.1),
                  child: const Text(
                    'Keranjang Belanja',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return ListTile(
                        title: Text(item.productName),
                        subtitle: Text('Rp ${item.price} x ${item.qty}'),
                        trailing: Text('Rp ${item.price * item.qty}'),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Rp $totalBelanja', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: cart.isEmpty ? null : _processPayment,
                          child: const Text('Bayar / Charge', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
