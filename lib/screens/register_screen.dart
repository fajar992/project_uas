
// screens/register_screen.dart


import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _namaCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _konfCtrl     = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  Future<void> _register() async {
    final nama     = _namaCtrl.text.trim();
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final konf     = _konfCtrl.text.trim();

    if (nama.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnack('Semua field wajib diisi!', Colors.red);
      return;
    }
    if (password != konf) {
      _showSnack('Password tidak sama!', Colors.red);
      return;
    }
    if (password.length < 6) {
      _showSnack('Password minimal 6 karakter!', Colors.red);
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await ApiService.register(nama, email, password);
      if (res['status'] == 'success') {
        _showSnack('Registrasi berhasil! Silakan login.', Colors.green);
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context);
      } else {
        _showSnack(res['message'], Colors.red);
      }
    } catch (e) {
      _showSnack('Gagal terhubung ke server!', Colors.red);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Daftar Akun',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Buat akun baru untuk mulai mencatat',
                  style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 32),

              _buildLabel('Nama Lengkap'),
              const SizedBox(height: 8),
              _buildField(_namaCtrl, 'Nama kamu', Icons.person_outline),
              const SizedBox(height: 16),

              _buildLabel('Email'),
              const SizedBox(height: 8),
              _buildField(_emailCtrl, 'contoh@email.com', Icons.email_outlined,
                  type: TextInputType.emailAddress),
              const SizedBox(height: 16),

              _buildLabel('Password'),
              const SizedBox(height: 8),
              _buildField(_passwordCtrl, '••••••••', Icons.lock_outlined,
                  obscure: _obscure,
                  suffix: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white54),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )),
              const SizedBox(height: 16),

              _buildLabel('Konfirmasi Password'),
              const SizedBox(height: 8),
              _buildField(_konfCtrl, '••••••••', Icons.lock_outlined,
                  obscure: _obscure),
              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C896),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Daftar Sekarang',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String t) =>
      Text(t, style: const TextStyle(color: Colors.white70, fontSize: 13));

  Widget _buildField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool obscure = false,
    TextInputType? type,
    Widget? suffix,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        prefixIcon: Icon(icon, color: Colors.white54),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFF1E2F42),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
