<?php

namespace Config;

use CodeIgniter\Config\BaseConfig;

class Cors extends BaseConfig
{
    public array $default = [
        // Allow Flutter web (Chrome) + any localhost port + production domains
        'allowedOrigins' => [
            'http://localhost:3000',
            'http://localhost:8080',
            'http://localhost:8081',
            'http://localhost:4040',
            'http://127.0.0.1:3000',
            'http://127.0.0.1:8080',
            'http://127.0.0.1:4040',
        ],

        // Allow any localhost:* port (covers flutter run random ports)
        'allowedOriginsPatterns' => [
            'http://localhost:\d+',
            'http://127\.0\.0\.1:\d+',
        ],

        'supportsCredentials' => true,

        'allowedHeaders' => [
            'Accept',
            'Authorization',
            'Content-Type',
            'X-Requested-With',
            'X-App-Version',
            'Origin',
        ],

        'exposedHeaders' => [],

        'allowedMethods' => [
            'GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS',
        ],

        'maxAge' => 7200,
    ];
}
