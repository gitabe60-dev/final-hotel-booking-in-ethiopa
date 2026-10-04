<?php

namespace App\Controllers\Api;

use CodeIgniter\Controller;

/**
 * Base controller for all API controllers.
 * Loads jwt + api helpers and exposes convenience methods.
 */
abstract class BaseApiController extends Controller
{
    protected $helpers = ['jwt', 'api'];

    // ─── Get authenticated user ID from JWT ──────────────────────────────────

    protected function authUserId(): int
    {
        return (int)($this->request->userId ?? jwt_user_id() ?? 0);
    }

    // ─── Get JSON body as array ───────────────────────────────────────────────

    protected function jsonBody(): array
    {
        $raw = $this->request->getBody();
        if (empty($raw)) return [];
        $decoded = json_decode($raw, true);
        return is_array($decoded) ? $decoded : [];
    }

    // ─── Validate required fields ─────────────────────────────────────────────

    protected function requireFields(array $data, array $fields): ?string
    {
        foreach ($fields as $field) {
            if (!isset($data[$field]) || $data[$field] === '') {
                return "Field '$field' is required.";
            }
        }
        return null;
    }
}
