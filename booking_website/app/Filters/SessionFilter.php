<?php

namespace App\Filters;

use CodeIgniter\Filters\FilterInterface;
use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;

/**
 * SessionFilter — protects web routes that require a guest login.
 * Stores the intended URL so the user is redirected back after auth.
 */
class SessionFilter implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null): mixed
    {
        if (!session()->get('user_id')) {
            // Store the page they were trying to reach
            $intended = (string)$request->getUri();
            session()->set('post_auth_redirect', $intended);
            return redirect()->to('/login')->with('error', 'Please log in to continue.');
        }
        return null;
    }

    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null): mixed
    {
        return null;
    }
}
