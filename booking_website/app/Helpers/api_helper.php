<?php

/**
 * API Response Helper
 * Standardised JSON response format matching the Flutter app's ApiService expectations:
 *   { "status": true|false, "message": "...", "data": {...}, "token": "..." }
 */

use CodeIgniter\HTTP\Response;

if (!function_exists('api_success')) {
    /**
     * Return a successful JSON response.
     *
     * @param mixed  $data
     * @param string $message
     * @param int    $code     HTTP status code
     * @param array  $extra    Extra top-level keys (e.g. ['token' => '...'])
     */
    function api_success(mixed $data = null, string $message = 'Success', int $code = 200, array $extra = []): Response
    {
        $body = array_merge([
            'status'  => true,
            'message' => $message,
            'data'    => $data,
        ], $extra);

        return response()->setStatusCode($code)
                         ->setContentType('application/json')
                         ->setJSON($body);
    }
}

if (!function_exists('api_error')) {
    /**
     * Return a failed JSON response.
     *
     * @param string $message
     * @param int    $code     HTTP status code (400, 401, 404, 422, 500 …)
     * @param mixed  $errors   Validation errors or extra detail
     */
    function api_error(string $message = 'Error', int $code = 400, mixed $errors = null): Response
    {
        $body = [
            'status'  => false,
            'message' => $message,
        ];

        if ($errors !== null) {
            $body['errors'] = $errors;
        }

        return response()->setStatusCode($code)
                         ->setContentType('application/json')
                         ->setJSON($body);
    }
}

if (!function_exists('api_paginated')) {
    /**
     * Return a paginated list response.
     */
    function api_paginated(array $items, int $total, int $limit, int $offset, string $message = 'Success'): Response
    {
        return api_success([
            'items'  => $items,
            'total'  => $total,
            'limit'  => $limit,
            'offset' => $offset,
            'pages'  => $limit > 0 ? (int)ceil($total / $limit) : 1,
        ], $message);
    }
}
