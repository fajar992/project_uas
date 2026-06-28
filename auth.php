<?php
// =============================================
// auth.php - API Login & Registrasi
// POST /auth.php?action=register
// POST /auth.php?action=login
// =============================================

require_once 'config.php';

$action = $_GET['action'] ?? '';
$input  = json_decode(file_get_contents("php://input"), true);

switch ($action) {

    // ── REGISTRASI ──────────────────────────────
    case 'register':
        $nama     = trim($input['nama'] ?? '');
        $email    = trim($input['email'] ?? '');
        $password = $input['password'] ?? '';

        if (!$nama || !$email || !$password) {
            response("error", "Semua field wajib diisi.");
        }

        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            response("error", "Format email tidak valid.");
        }

        $conn = getConnection();

        // Cek email sudah terdaftar
        $cek = $conn->prepare("SELECT id FROM users WHERE email = ?");
        $cek->bind_param("s", $email);
        $cek->execute();
        $cek->store_result();
        if ($cek->num_rows > 0) {
            response("error", "Email sudah terdaftar.");
        }
        $cek->close();

        // Simpan user baru
        $hash = password_hash($password, PASSWORD_BCRYPT);
        $stmt = $conn->prepare("INSERT INTO users (nama, email, password) VALUES (?, ?, ?)");
        $stmt->bind_param("sss", $nama, $email, $hash);

        if ($stmt->execute()) {
            response("success", "Registrasi berhasil.", ["user_id" => $conn->insert_id, "nama" => $nama]);
        } else {
            response("error", "Registrasi gagal.");
        }
        break;

    // ── LOGIN ────────────────────────────────────
    case 'login':
        $email    = trim($input['email'] ?? '');
        $password = $input['password'] ?? '';

        if (!$email || !$password) {
            response("error", "Email dan password wajib diisi.");
        }

        $conn = getConnection();
        $stmt = $conn->prepare("SELECT id, nama, password FROM users WHERE email = ?");
        $stmt->bind_param("s", $email);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows === 0) {
            response("error", "Email tidak ditemukan.");
        }

        $user = $result->fetch_assoc();

        if (!password_verify($password, $user['password'])) {
            response("error", "Password salah.");
        }

        response("success", "Login berhasil.", [
            "user_id" => $user['id'],
            "nama"    => $user['nama'],
            "email"   => $email
        ]);
        break;

    default:
        response("error", "Action tidak dikenali.");
}
?>
