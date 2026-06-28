
// services/api_service.dart
// Ganti BASE_URL sesuai IP laptop / server 
// Contoh: http://192.168.1.5/keuangan_api


import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaksi_model.dart'; 

class ApiService {
  //  Pastikan IP Laptop kamu saat ini masih '192.168.0.110'. 
  // Jika laptop ganti Wi-Fi, IP ini wajib diganti sesuai IP baru!
  static const String baseUrl = 'http://10.80.225.159/keuangan_uas'; 

  //  AUTH 

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth.php?action=login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> register(
      String nama, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth.php?action=register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nama': nama, 'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  //  TRANSAKSI 

  /// READ: Ambil semua transaksi beserta ringkasan saldo
  static Future<Map<String, dynamic>> getTransaksi(int userId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/transaksi.php?user_id=$userId'),
    );
    return jsonDecode(res.body);
  }

  /// CREATE: Tambah transaksi baru
  static Future<Map<String, dynamic>> tambahTransaksi(Transaksi t) async {
    final res = await http.post(
      Uri.parse('$baseUrl/transaksi.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(t.toJson()),
    );
    return jsonDecode(res.body);
  }

  /// UPDATE: Edit transaksi
  static Future<Map<String, dynamic>> updateTransaksi(int id, Transaksi t) async {
    final res = await http.put(
      Uri.parse('$baseUrl/transaksi.php?id=$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(t.toJson()),
    );
    return jsonDecode(res.body);
  }

  /// DELETE: Hapus transaksi
  static Future<Map<String, dynamic>> hapusTransaksi(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/transaksi.php?id=$id'),
    );
    return jsonDecode(res.body);
  }
}