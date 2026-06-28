
// screens/form_transaksi_screen.dart
// buat create ama apdet


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_uas/models/transaksi_model.dart';
// import '../models/transaksi_model.dart';
import '../services/api_service.dart';

class FormTransaksiScreen extends StatefulWidget {
  final int userId;
  final Transaksi? transaksi; // null = tambah baru, isi = edit

  const FormTransaksiScreen({
    super.key,
    required this.userId,
    this.transaksi,
  });

  @override
  State<FormTransaksiScreen> createState() => _FormTransaksiScreenState();
}

class _FormTransaksiScreenState extends State<FormTransaksiScreen> {
  final _judulCtrl   = TextEditingController();
  final _jumlahCtrl  = TextEditingController();
  final _catatanCtrl = TextEditingController();

  String _tipe     = 'pemasukan';
  String _kategori = 'Lainnya';
  DateTime _tanggal = DateTime.now();
  bool _loading    = false;

  bool get _isEdit => widget.transaksi != null;

  final List<String> _kategoriList = [
    'Gaji', 'Makanan', 'Transport', 'Belanja',
    'Kesehatan', 'Hiburan', 'Tagihan', 'Lainnya','pakaian'
  ];

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final t = widget.transaksi!;
      _judulCtrl.text   = t.judul;
      _jumlahCtrl.text  = t.jumlah.toStringAsFixed(0);
      _catatanCtrl.text = t.catatan;
      _tipe             = t.tipe;
      _kategori         = t.kategori;
      _tanggal          = DateTime.tryParse(t.tanggal) ?? DateTime.now();
    }
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00C896),
              surface: Color(0xFF1E2F42)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  Future<void> _simpan() async {
    final judul  = _judulCtrl.text.trim();
    final jumlah = double.tryParse(_jumlahCtrl.text.replaceAll('.', '')) ?? 0;

    if (judul.isEmpty || jumlah <= 0) {
      _showSnack('Judul dan jumlah wajib diisi!', Colors.red);
      return;
    }

    setState(() => _loading = true);

    final transaksi = Transaksi(
      id: _isEdit ? widget.transaksi!.id : 0,
      userId: widget.userId,
      judul: judul,
      jumlah: jumlah,
      tipe: _tipe,
      kategori: _kategori,
      catatan: _catatanCtrl.text.trim(),
      tanggal: DateFormat('yyyy-MM-dd').format(_tanggal),
    );

    try {
      final res = _isEdit
          ? await ApiService.updateTransaksi(widget.transaksi!.id, transaksi)
          : await ApiService.tambahTransaksi(transaksi);

      _showSnack(res['message'],
          res['status'] == 'success' ? Colors.green : Colors.red);

      if (res['status'] == 'success' && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnack('Gagal terhubung ke server!', Colors.red);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2F42),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_isEdit ? 'Edit Transaksi' : 'Tambah Transaksi',
            style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  Pilih Tipe
            const _Label('Tipe Transaksi'),
            const SizedBox(height: 10),
            Row(
              children: [
                _TipeButton(
                  label: '⬇ Pemasukan',
                  selected: _tipe == 'pemasukan',
                  color: const Color(0xFF00C896),
                  onTap: () => setState(() => _tipe = 'pemasukan'),
                ),
                const SizedBox(width: 12),
                _TipeButton(
                  label: '⬆ Pengeluaran',
                  selected: _tipe == 'pengeluaran',
                  color: const Color(0xFFE74C3C),
                  onTap: () => setState(() => _tipe = 'pengeluaran'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Judul ──────────────────────────────
            const _Label('Judul'),
            const SizedBox(height: 8),
            _buildTextField(_judulCtrl, 'Contoh: Gaji Bulanan', Icons.title),
            const SizedBox(height: 16),

            // ── Jumlah ─────────────────────────────
            const _Label('Jumlah (Rp)'),
            const SizedBox(height: 8),
            _buildTextField(
              _jumlahCtrl,
              '0',
              Icons.attach_money,
              type: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // ── Kategori ───────────────────────────
            const _Label('Kategori'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2F42),
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButton<String>(
                value: _kategori,
                isExpanded: true,
                dropdownColor: const Color(0xFF1E2F42),
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.white),
                items: _kategoriList
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (v) => setState(() => _kategori = v!),
              ),
            ),
            const SizedBox(height: 16),

            // ── Tanggal ────────────────────────────
            const _Label('Tanggal'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pilihTanggal,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2F42),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.white54, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('dd MMMM yyyy', 'id_ID').format(_tanggal),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: Colors.white38),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Catatan ────────────────────────────
            const _Label('Catatan (opsional)'),
            const SizedBox(height: 8),
            TextField(
              controller: _catatanCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tambahkan catatan...',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: const Color(0xFF1E2F42),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 32),

            // ── Tombol Simpan ──────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _tipe == 'pemasukan'
                      ? const Color(0xFF00C896)
                      : const Color(0xFFE74C3C),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isEdit ? 'Simpan Perubahan' : 'Tambah Transaksi',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType? type,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        prefixIcon: Icon(icon, color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1E2F42),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(color: Colors.white70, fontSize: 13));
}

class _TipeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _TipeButton(
      {required this.label,
      required this.selected,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? color : const Color(0xFF1E2F42),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: selected ? color : Colors.transparent, width: 2),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: selected ? Colors.white : Colors.white54,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
