<?php

require __DIR__ . '/vendor/autoload.php';

// Configuration class
class Config
{
    public static $oemproUrl = null;
    public static $oemproAdminApiKey = null;
    public static $aliasUsername = 'catchall';
}

// Server class
class Server
{
    public function __construct()
    {
    }

    public function initConfig()
    {
        $iniConfig = parse_ini_file(__DIR__ . '/.env');

        if (isset($iniConfig['oempro_url'])) {
            Config::$oemproUrl = $iniConfig['oempro_url'];
        }

        if (isset($iniConfig['oempro_admin_api_key'])) {
            Config::$oemproAdminApiKey = $iniConfig['oempro_admin_api_key'];
        }
    }

    public function run()
    {
        // Configuration initialization
        $this->initConfig();;

        // Set up the server
        $socket = new React\Socket\SocketServer('127.0.0.1:8000', []);

        // Event: Connection is made
        $socket->on('connection', function (React\Socket\ConnectionInterface $connection) {
            // Event: Data is received
            $connection->on('data', function ($chunk) use ($connection) {
                // Identify the target email domain from the TCP data
                $targetEmailDomain = preg_replace('/^get /i', '', trim($chunk));

                // Validate the email address domain via Oempro
                try {
                    $httpClient = new GuzzleHttp\Client();
                    $httpResponse = $httpClient->request('GET', Config::$oemproUrl . 'api/v1/inbound-relay-domain-check?domain=' . $targetEmailDomain, [
                        'headers' => [
                            'Authorization' => 'Bearer ' . Config::$oemproAdminApiKey,
                            'Accept' => 'application/json',
                        ],
                    ]);

                    if ($httpResponse->getStatusCode() == 200) {
                        $connection->write("200 " . Config::$aliasUsername . "\n");
                    }
                } catch (Exception $e) {
                    // A problem has occurred when trying to make a check on Oempro
                    if ($e->getResponse()) {
                        $response = $e->getResponse();

                        if ($response->getStatusCode() >= 400 && $response->getStatusCode() <= 499) {
                            $connection->write("400 Temporary error has occurred\n");
                        } elseif ($response->getStatusCode() >= 500 && $response->getStatusCode() <= 599) {
                            $connection->write("500 Relay access denied\n");
                        }
                    } else {
                        $connection->write("400 Temporary error has occurred\n");
                    }
                }

                $connection->end();
            });

            // Event: Connection ended
            $connection->on('end', function () {
            });

            // Event: Error occurred
            $connection->on('error', function () {
            });

            // Event: Connection closed
            $connection->on('close', function () {
            });
        });

        // What to do if an error occurs during the connection
        $socket->on('error', function (Exception $e) {
            echo 'Error: ' . $e->getMessage() . PHP_EOL;
        });
    }
}

// Run the server
$server = new Server();
$server->run();