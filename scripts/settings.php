<?php
// settings.php personnalisé pour Drupal

// ...autres paramètres Drupal par défaut...

if (getenv('DRUPAL_TRUSTED_HOST_PATTERNS')) {
    $settings['trusted_host_patterns'] = explode(',', getenv('DRUPAL_TRUSTED_HOST_PATTERNS'));
}

// ...autres paramètres Drupal par défaut...
$databases['default']['default'] = array (
  'database' => 'database',
  'username' => 'spaceuser',
  'password' => 'mycoolsecret',
  'prefix' => '',
  'host' => 'db',
  'port' => '3306',
  'isolation_level' => 'READ COMMITTED',
  'driver' => 'mysql',
  'namespace' => 'Drupal\\mysql\\Driver\\Database\\mysql',
  'autoload' => 'core/modules/mysql/src/Driver/Database/mysql/',
);
$settings['hash_salt'] = 'FmzFZyZxGzZdrB4GZ7-CyAYc5w8_jg-_8a05HKWcZKqhWjFUHfnc4qQ4rQalRFIj10GaA_Es5w';
$settings['config_sync_directory'] = 'sites/default/files/config_mikRNdRAdE26WRCm5bLklgrVtb2sc1F7IQnknDqOkg38XXKYIzo96jBN60m-NGALYgS3CdDVbA/sync';
