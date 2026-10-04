<?php

namespace Config;

use CodeIgniter\Config\BaseConfig;

class Jwt extends BaseConfig
{
    /**
     * JWT secret key — override via .env  jwt.secret
     */
    public string $secret = 'CHANGE_THIS_SECRET_KEY_IN_ENV_FILE';

    /**
     * Access token TTL in seconds  (24 h)
     */
    public int $expire = 86400;

    /**
     * Refresh token TTL in seconds (7 days)
     */
    public int $refreshExpire = 604800;

    /**
     * JWT algorithm
     */
    public string $algorithm = 'HS256';

    public function __construct()
    {
        parent::__construct();

        if (getenv('jwt.secret') !== false) {
            $this->secret = getenv('jwt.secret');
        }
        if (getenv('jwt.expire') !== false) {
            $this->expire = (int) getenv('jwt.expire');
        }
        if (getenv('jwt.refresh_expire') !== false) {
            $this->refreshExpire = (int) getenv('jwt.refresh_expire');
        }
    }
}
