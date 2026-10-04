<?php

use CodeIgniter\Boot;
use Config\Paths;

// ── PHP Version check ────────────────────────────────────────────────────────
$minPhpVersion = '8.2';
if (version_compare(PHP_VERSION, $minPhpVersion, '<')) {
    header('HTTP/1.1 503 Service Unavailable.', true, 503);
    echo sprintf('Your PHP version must be %s or higher. Current: %s', $minPhpVersion, PHP_VERSION);
    exit(1);
}

// ── Set current directory ────────────────────────────────────────────────────
define('FCPATH', __DIR__ . DIRECTORY_SEPARATOR);
if (getcwd() . DIRECTORY_SEPARATOR !== FCPATH) {
    chdir(FCPATH);
}

// ── Bootstrap ────────────────────────────────────────────────────────────────
require FCPATH . '../app/Config/Paths.php';
$paths = new Paths();
require $paths->systemDirectory . '/Boot.php';
exit(Boot::bootWeb($paths));
