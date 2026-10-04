<?php

namespace App\Filters;

use CodeIgniter\Filters\FilterInterface;
use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;

/**
 * JWT Authentication Filter
 *
 * Apply to any route that requires authentication:
 *   $routes->get('api/v1/guest/profile', ..., ['filter' => 'jwt']);
 *
 * Or register in app/Config/Filters.php under $aliases:
 *   'jwt' => \App\Filters\JwtFilter::class
 */
class JwtFilter implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null): mixed
    {
        helper(['jwt', 'api']);

        $token = jwt_from_request();

        if (!$token) {
            return api_error('Unauthorized: No token provided', 401);
        }

        $payload = jwt_decode($token);

        if (!$payload) {
            return api_error('Unauthorized: Invalid or expired token', 401);
        }

        // Inject user_id into request so controllers can read it
        $request->userId = (int)($payload['user_id'] ?? 0);

        return null; // continue
    }

    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null): mixed
    {
        return null;
    }
}
