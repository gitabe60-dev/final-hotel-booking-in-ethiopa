<?php

namespace Config;

use CodeIgniter\Database\Config;

/**
 * Database Configuration
 * Uses dedicated app user 'dallol_app' — never affected by postgres password resets
 */
class Database extends Config
{
    public string $filesPath   = APPPATH . 'Database' . DIRECTORY_SEPARATOR;
    public string $defaultGroup = 'default';

    public array $default = [
        'DSN'          => '',
        'hostname'     => '127.0.0.1',
        'username'     => 'dallol_app',
        'password'     => '1212',
        'database'     => 'dallol_booking',
        'DBDriver'     => 'Postgre',
        'DBPrefix'     => '',
        'pConnect'     => false,
        'DBDebug'      => true,
        'charset'      => 'utf8',
        'DBCollat'     => '',
        'swapPre'      => '',
        'encrypt'      => false,
        'compress'     => false,
        'strictOn'     => false,
        'failover'     => [],
        'port'         => 5432,
        'schema'       => 'public',
        'numberNative' => false,
    ];

    public array $tests = [
        'DSN'          => '',
        'hostname'     => '127.0.0.1',
        'username'     => 'dallol_app',
        'password'     => '1212',
        'database'     => 'dallol_booking',
        'DBDriver'     => 'Postgre',
        'DBPrefix'     => 'test_',
        'pConnect'     => false,
        'DBDebug'      => true,
        'charset'      => 'utf8',
        'DBCollat'     => '',
        'swapPre'      => '',
        'encrypt'      => false,
        'compress'     => false,
        'strictOn'     => false,
        'failover'     => [],
        'port'         => 5432,
        'schema'       => 'public',
        'numberNative' => false,
    ];
}
