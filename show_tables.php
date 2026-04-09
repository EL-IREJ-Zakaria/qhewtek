<?php
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

if ($argc < 6) {
    fwrite(STDERR, "Usage: php show_tables.php <host> <port> <user> <pass> <db>\n");
    exit(1);
}

[$script, $host, $port, $user, $pass, $db] = $argv;

$mysqli = mysqli_init();
$mysqli->real_connect($host, $user, $pass, $db, (int)$port);
$mysqli->set_charset("utf8mb4");

$result = $mysqli->query("SHOW TABLES");
while ($row = $result->fetch_array(MYSQLI_NUM)) {
    echo $row[0] . PHP_EOL;
}
$result->free();
$mysqli->close();
