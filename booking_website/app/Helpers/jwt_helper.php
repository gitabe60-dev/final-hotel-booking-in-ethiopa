<?php

/**
 * JWT Helper
 * Wraps firebase/php-jwt for CodeIgniter 4
 *
 * Usage:
 *   helper('jwt');
 *   $token = jwt_generate(['user_id' => 1, 'email' => 'a@b.com']);
 *   $payload = jwt_decode($token);
 */

use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Config\Jwt as JwtConfig;

if (!function_exists('jwt_generate')) {
    /**
     * Generate an access token.
     *
     * @param array $payload  Extra claims to embed (user_id, email, etc.)
     * @return string  Signed JWT string
     */
    function jwt_generate(array $payload): string
    {
        $cfg = new JwtConfig();

        $now = time();
        $claims = array_merge($payload, [
            'iat' => $now,
            'nbf' => $now,
            'exp' => $now + $cfg->expire,
        ]);

        return JWT::encode($claims, $cfg->secret, $cfg->algorithm);
    }
}

if (!function_exists('jwt_generate_refresh')) {
    /**
     * Generate a refresh token (longer TTL, stored in DB).
     */
    function jwt_generate_refresh(array $payload): string
    {
        $cfg = new JwtConfig();

        $now = time();
        $claims = array_merge($payload, [
            'type' => 'refresh',
            'iat'  => $now,
            'nbf'  => $now,
            'exp'  => $now + $cfg->refreshExpire,
        ]);

        return JWT::encode($claims, $cfg->secret, $cfg->algorithm);
    }
}

if (!function_exists('jwt_decode')) {
    /**
     * Decode and verify a JWT.
     *
     * @param string $token
     * @return array|null  Decoded payload array, or null on failure
     */
    function jwt_decode(string $token): ?array
    {
        try {
            $cfg     = new JwtConfig();
            $decoded = JWT::decode($token, new Key($cfg->secret, $cfg->algorithm));
            return (array) $decoded;
        } catch (\Exception $e) {
            return null;
        }
    }
}

if (!function_exists('jwt_from_request')) {
    /**
     * Extract the Bearer token from the current request's Authorization header.
     */
    function jwt_from_request(): ?string
    {
        $request = \Config\Services::request();
        $header  = $request->getHeaderLine('Authorization');

        if (!$header) return null;

        if (preg_match('/^Bearer\s+(.+)$/i', $header, $m)) {
            return $m[1];
        }

        return null;
    }
}

if (!function_exists('jwt_user_id')) {
    /**
     * Get the authenticated user ID from the current request token.
     * Returns null if invalid / unauthenticated.
     */
    function jwt_user_id(): ?int
    {
        $token = jwt_from_request();
        if (!$token) return null;

        $payload = jwt_decode($token);
        return isset($payload['user_id']) ? (int)$payload['user_id'] : null;
    }
}
