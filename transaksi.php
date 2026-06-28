<?php
// =============================================
// transaksi.php - API CRUD Transaksi
// GET    /transaksi.php?user_id=1  → Read semua
// POST   /transaksi.php            → Create
// PUT    /transaksi.php?id=1       → Update
// DELETE /transaksi.php?id=1       → Delete
// =============================================

require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];
$input  = json_decode(file_get_contents("php://input"), true);

switch ($method) {

    // ── READ ─────────────────────────────────────
    case 'GET':
        $user_id = intval($_GET['user_id'] ?? 0);
        if (!$user_id) response("error", "user_id wajib diisi.");

        $conn = getConnection();

        $stmt = $conn->prepare("SELECT * FROM transaksi WHERE user_id = ? ORDER BY tanggal DESC, created_at DESC");
        $stmt->bind_param("i", $user_id);
        $stmt->execute();
        $rows = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);

        $s2 = $conn->prepare("SELECT 
            SUM(CASE WHEN tipe='pemasukan' THEN jumlah ELSE 0 END) AS total_pemasukan,
            SUM(CASE WHEN tipe='pengeluaran' THEN jumlah ELSE 0 END) AS total_pengeluaran
            FROM transaksi WHERE user_id = ?");
        $s2->bind_param("i", $user_id);
        $s2->execute();
        $ring = $s2->get_result()->fetch_assoc();

        $masuk  = floatval($ring['total_pemasukan'] ?? 0);
        $keluar = floatval($ring['total_pengeluaran'] ?? 0);

        response("success", "OK", [
            "transaksi"         => $rows,
            "total_pemasukan"   => $masuk,
            "total_pengeluaran" => $keluar,
            "saldo"             => $masuk - $keluar
        ]);
        break;

    // ── CREATE ────────────────────────────────────
    case 'POST':
        $user_id  = intval($input['user_id']  ?? 0);
        $judul    = trim($input['judul']    ?? '');
        $jumlah   = floatval($input['jumlah']   ?? 0);
        $tipe     = $input['tipe']     ?? '';
        $kategori = $input['kategori'] ?? 'Lainnya';
        $catatan  = $input['catatan']  ?? '';
        $tanggal  = $input['tanggal']  ?? date('Y-m-d');

        if (!$user_id || !$judul || $jumlah <= 0 || !in_array($tipe, ['pemasukan','pengeluaran'])) {
            response("error", "Data tidak lengkap atau tidak valid.");
        }

        $conn = getConnection();
        $stmt = $conn->prepare("INSERT INTO transaksi (user_id, judul, jumlah, tipe, kategori, catatan, tanggal) VALUES (?,?,?,?,?,?,?)");
        $stmt->bind_param("isdssss", $user_id, $judul, $jumlah, $tipe, $kategori, $catatan, $tanggal);

        if ($stmt->execute()) {
            response("success", "Transaksi berhasil ditambahkan.", ["id" => $conn->insert_id]);
        } else {
            response("error", "Gagal: " . $conn->error);
        }
        break;

    // ── UPDATE ────────────────────────────────────
    case 'PUT':
        $id       = intval($_GET['id'] ?? 0);
        $judul    = trim($input['judul']    ?? '');
        $jumlah   = floatval($input['jumlah']   ?? 0);
        $tipe     = $input['tipe']     ?? '';
        $kategori = $input['kategori'] ?? 'Lainnya';
        $catatan  = $input['catatan']  ?? '';
        $tanggal  = $input['tanggal']  ?? date('Y-m-d');

        if (!$id || !$judul || $jumlah <= 0 || !in_array($tipe, ['pemasukan','pengeluaran'])) {
            response("error", "Data tidak lengkap.");
        }

        $conn = getConnection();
        $stmt = $conn->prepare("UPDATE transaksi SET judul=?, jumlah=?, tipe=?, kategori=?, catatan=?, tanggal=? WHERE id=?");
        $stmt->bind_param("sdssssi", $judul, $jumlah, $tipe, $kategori, $catatan, $tanggal, $id);

        if ($stmt->execute()) {
            response("success", "Transaksi berhasil diupdate.");
        } else {
            response("error", "Gagal: " . $conn->error);
        }
        break;

    // ── DELETE ────────────────────────────────────
    case 'DELETE':
        $id = intval($_GET['id'] ?? 0);
        if (!$id) response("error", "ID wajib diisi.");

        $conn = getConnection();
        $stmt = $conn->prepare("DELETE FROM transaksi WHERE id = ?");
        $stmt->bind_param("i", $id);

        if ($stmt->execute()) {
            response("success", "Transaksi berhasil dihapus.");
        } else {
            response("error", "Gagal: " . $conn->error);
        }
        break;

    default:
        response("error", "Method tidak dikenali.");
}
?>
