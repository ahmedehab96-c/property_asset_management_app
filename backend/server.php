<?php

$publicPath = getcwd();

$uri = urldecode(
    parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?? ''
);

// This file allows us to emulate Apache's "mod_rewrite" functionality from the
// built-in PHP web server. This provides a convenient way to test a Laravel
// application without having installed a "real" web server software here.
if ($uri !== '/' && file_exists($publicPath.$uri)) {
    return false;
}

// PHP's built-in server does its own CGI-style SCRIPT_NAME/PATH_INFO split
// whenever a requested path traverses an existing directory that contains an
// index file (e.g. public/dashboard/index.html, the built React SPA's entry
// point) — corrupting Laravel's route matching for any deep link under that
// mount, such as /dashboard/properties. Force these back to the real front
// controller so Laravel sees the full, uncorrupted request path.
$_SERVER['SCRIPT_NAME'] = '/index.php';
$_SERVER['PHP_SELF'] = '/index.php';
$_SERVER['SCRIPT_FILENAME'] = $publicPath.'/index.php';
unset($_SERVER['PATH_INFO'], $_SERVER['ORIG_SCRIPT_NAME']);

require_once $publicPath.'/index.php';
