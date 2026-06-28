
// models/transaksi_model.dart


class Transaksi {
  final int id;
  final int userId;
  final String judul;
  final double jumlah;
  final String tipe; // 'pemasukan' atau 'pengeluaran'
  final String kategori;
  final String catatan;
  final String tanggal;

  Transaksi({
    required this.id,
    required this.userId,
    required this.judul,
    required this.jumlah,
    required this.tipe,
    required this.kategori,
    required this.catatan,
    required this.tanggal,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      judul: json['judul'] ?? '',
      jumlah: double.parse(json['jumlah'].toString()),
      tipe: json['tipe'] ?? '',
      kategori: json['kategori'] ?? 'Lainnya',
      catatan: json['catatan'] ?? '',
      tanggal: json['tanggal'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'judul': judul,
      'jumlah': jumlah,
      'tipe': tipe,
      'kategori': kategori,
      'catatan': catatan,
      'tanggal': tanggal,
    };
  }
}

class User {
  final int id;
  final String nama;
  final String email;

  User({required this.id, required this.nama, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['user_id'].toString()),
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
