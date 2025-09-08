<?php
// index.php → Webservice API for Distance Education Dashboard

// ---- Database Connection ----
$host = "localhost"; 
$user = "root";      // default in XAMPP
$pass = "";          // default password is empty
$db   = "college_db"; // change to your DB name

$conn = new mysqli($host, $user, $pass, $db);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "DB Connection Failed: " . $conn->connect_error]));
}

// ---- Simple API Router ----
$action = isset($_GET['action']) ? $_GET['action'] : '';

if ($action == "subjects") {
    $sql = "SELECT subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active FROM subject";
    $result = $conn->query($sql);

    $subjects = [];
    while ($row = $result->fetch_assoc()) {
        $subjects[] = $row;
    }

    echo json_encode([
        "status" => "success",
        "count"  => count($subjects),
        "data"   => $subjects
    ]);
}
else {
    echo json_encode(["status" => "error", "message" => "Invalid API endpoint"]);
}

$conn->close();
?>
