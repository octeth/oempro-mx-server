<?php

require __DIR__ . '/vendor/autoload.php';

$socket = new React\Socket\SocketServer('127.0.0.1:8000', []);

$socket->on('connection', function (React\Socket\ConnectionInterface $connection) {
    $connection->on('data', function($chunk) use ($connection) {
        $targetEmailDomain = preg_replace('/^get /i', '', trim($chunk));

        // TODO: Check if it's allowed to accept the email
        if ($targetEmailDomain != 'c.com' && preg_match('/@c.com/i', $targetEmailDomain) == 0) {
            $connection->write("500 Email address does not exist\n");
            // $connection->write("400 Not Allowed\n");
        }

        if (preg_match('/^tcp:\/\/127.0.0.1/i', $connection->getRemoteAddress()) > 0) {
            $connection->write("200 root\n");
        } else {
            $connection->end();
        }
    });

    $connection->on('end', function() {});
    $connection->on('error', function() {});
    $connection->on('close', function() {});
});

$socket->on('error', function (Exception $e) {
    echo 'Error: ' . $e->getMessage() . PHP_EOL;
});

echo 'Listening on ' . $socket->getAddress() . PHP_EOL;