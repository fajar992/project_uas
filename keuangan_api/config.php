<?php
// =============================================
// config.php - Koneksi Database
// Sesuaikan host, user, password jika perlu
// =============================================

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

define('DB_HOST', 'localhost');
define('DB_USER', 'root');       // Ganti sesuai user MySQL kamu
define('DB_PASS', '');           // Ganti sesuai password MySQL kamu
define('DB_NAME', 'db_keuangan');

function getConnection() {
    $conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
    if ($conn->connect_error) {
        http_response_code(500);
        echo json_encode(["status" => "error", "message" => "Koneksi gagal: " . $conn->connect_error]);
        exit();
    }
    $conn->set_charset("utf8");
    return $conn;
}

function response($status, $message, $data = null) {
    $result = ["status" => $status, "message" => $message];
    if ($data !== null) $result["data"] = $data;
    echo json_encode($result);
    exit();
}
?>
