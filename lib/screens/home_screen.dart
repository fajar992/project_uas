
// screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaksi_model.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'form_transaksi_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _userId        = 0;
  String _nama       = '';
  List<Transaksi> _transaksi = [];
  double _saldo      = 0;
  double _pemasukan  = 0;
  double _pengeluaran = 0;
  bool _loading      = true;

  final _currency = NumberFormat.currency(
      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id') ?? 0;
    _nama   = prefs.getString('nama') ?? '';
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getTransaksi(_userId);
      if (res['status'] == 'success') {
        final data = res['data'];
        setState(() {
          _transaksi   = (data['transaksi'] as List)
              .map((e) => Transaksi.fromJson(e))
              .toList();
          _saldo       = double.parse(data['saldo'].toString());
          _pemasukan   = double.parse(data['total_pemasukan'].toString());
          _pengeluaran = double.parse(data['total_pengeluaran'].toString());
        });
      }
    } catch (e) {
      _showSnack('Gagal memuat data!', Colors.red);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _hapus(int id) async {
    final konfirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2F42),
        title: const Text('Hapus Transaksi',
            style: TextStyle(color: Colors.white)),
        content: const Text('Yakin ingin menghapus transaksi ini?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal', style: TextStyle(color: Colors.white54))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (konfirm == true) {
      final res = await ApiService.hapusTransaksi(id);
      _showSnack(res['message'],
          res['status'] == 'success' ? Colors.green : Colors.red);
      if (res['status'] == 'success') _fetchData();
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: color));
  }

  void _goToForm({Transaksi? transaksi}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FormTransaksiScreen(userId: _userId, transaksi: transaksi),
      ),
    );
    if (result == true) _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchData,
          color: const Color(0xFF00C896),
          child: CustomScrollView(
            slivers: [
              // ── Header ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Halo, $_nama 👋',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                          const Text('Keuanganmu',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white54),
                        onPressed: _logout,
                        tooltip: 'Keluar',
                      ),
                    ],
                  ),
                ),
              ),

              // ── Kartu Saldo ──────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _saldo >= 0
                            ? [const Color(0xFF00C896), const Color(0xFF009B73)]
                            : [const Color(0xFFE74C3C), const Color(0xFFC0392B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (_saldo >= 0
                                  ? const Color(0xFF00C896)
                                  : const Color(0xFFE74C3C))
                              .withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text('Total Saldo',
        style: TextStyle(color: Colors.white70, fontSize: 13)),
    const SizedBox(height: 8),
    Text(
      _currency.format(_saldo),
      style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold),
    ),
    if (_saldo < 0)
      const Padding(
        padding: EdgeInsets.only(top: 4),
        child: Text('⚠️ Pengeluaran melebihi pemasukan!',
            style: TextStyle(color: Colors.white70, fontSize: 12)),
      ),
    const SizedBox(height: 20),
    Row(
      children: [
        Expanded(
          child: _ringkasan('Pemasukan', _pemasukan, Icons.arrow_downward),
        ),
        const SizedBox(width: 12),
        Expanded(
          // Di sini tetap memanggil fungsi _ringkasan biasa
          child: _ringkasan('Pengeluaran', _pengeluaran, Icons.arrow_upward),
        ),
      ],
    ),
  ],
),
                  ),
                ),
              ),

              // ── Judul Daftar ─────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Riwayat Transaksi',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      Text('${_transaksi.length} transaksi',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
              ),

              // ── Daftar Transaksi ─────────────────────
              _loading
                  ? const SliverFillRemaining(
                      child: Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF00C896))))
                  : _transaksi.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long,
                                    color: Colors.white24, size: 64),
                                const SizedBox(height: 12),
                                const Text('Belum ada transaksi',
                                    style: TextStyle(color: Colors.white38)),
                                const Text('Tekan + untuk menambahkan',
                                    style: TextStyle(
                                        color: Colors.white24, fontSize: 12)),
                              ],
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) => _itemTransaksi(_transaksi[i]),
                              childCount: _transaksi.length,
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),

      // ── FAB ─────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _goToForm(),
        backgroundColor: const Color(0xFF00C896),
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('Tambah', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _ringkasan(String label, double nilai, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: Colors.white70, fontSize: 11)),
                Text(_currency.format(nilai),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemTransaksi(Transaksi t) {
    final isPemasukan = t.tipe == 'pemasukan';
    final color = isPemasukan ? const Color(0xFF00C896) : const Color(0xFFE74C3C);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2F42),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isPemasukan ? Icons.arrow_downward : Icons.arrow_upward,
            color: color,
            size: 22,
          ),
        ),
        title: Text(t.judul,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text('${t.kategori} • ${t.tanggal}',
            style: const TextStyle(color: Colors.white38, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isPemasukan ? '+' : '-'}${_currency.format(t.jumlah)}',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white38, size: 20),
              color: const Color(0xFF1E2F42),
              onSelected: (val) {
                if (val == 'edit') _goToForm(transaksi: t);
                if (val == 'hapus') _hapus(t.id);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit, color: Colors.white54, size: 18),
                      SizedBox(width: 8),
                      Text('Edit', style: TextStyle(color: Colors.white)),
                    ])),
                const PopupMenuItem(
                    value: 'hapus',
                    child: Row(children: [
                      Icon(Icons.delete, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('Hapus', style: TextStyle(color: Colors.red)),
                    ])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
