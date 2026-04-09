<?php
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

if ($argc < 7) {
    fwrite(STDERR, "Usage: php import_schema.php <host> <port> <user> <pass> <db> <sqlfile>\n");
    exit(1);
}

[$script, $host, $port, $user, $pass, $db, $sqlFile] = $argv;

if (!file_exists($sqlFile)) {
    fwrite(STDERR, "Fichier SQL introuvable: $sqlFile\n");
    exit(1);
}

$sql = file_get_contents($sqlFile);
if ($sql === false) {
    fwrite(STDERR, "Impossible de lire le fichier SQL.\n");
    exit(1);
}

try {
    $mysqli = mysqli_init();
    $mysqli->real_connect($host, $user, $pass, $db, (int)$port);
    $mysqli->set_charset("utf8mb4");

    $mysqli->multi_query($sql);

    do {
        if ($result = $mysqli->store_result()) {
            $result->free();
        }
    } while ($mysqli->more_results() && $mysqli->next_result());

    echo "IMPORT_OK\n";
    $mysqli->close();
} catch (Throwable $e) {
    fwrite(STDERR, "IMPORT_ERROR: " . $e->getMessage() . "\n");
    exit(1);
}
