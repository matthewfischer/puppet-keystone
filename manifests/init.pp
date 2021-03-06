#
# Module for managing keystone config.
#
# == Parameters
#
#   [package_ensure] Desired ensure state of packages. Optional. Defaults to present.
#     accepts latest or specific versions.
#   [bind_host] Host that keystone binds to.
#   [bind_port] Port that keystone binds to.
#   [public_port]
#   [compute_port]
#   [admin_port]
#   [admin_port] Port that can be used for admin tasks.
#   [admin_token] Admin token that can be used to authenticate as a keystone
#     admin. Required.
#   [verbose] Rather keystone should log at verbose level. Optional.
#     Defaults to False.
#   [debug] Rather keystone should log at debug level. Optional.
#     Defaults to False.
#   [use_syslog] Use syslog for logging. Optional.
#     Defaults to False.
#   [log_facility] Syslog facility to receive log lines. Optional.
#   [catalog_type] Type of catalog that keystone uses to store endpoints,services. Optional.
#     Defaults to sql. (Also accepts template)
#   [token_provider] Format keystone uses for tokens. Optional.
#     Defaults to 'keystone.token.providers.pki.Provider'
#     Supports PKI and UUID.
#   [token_driver] Driver to use for managing tokens.
#     Optional.  Defaults to 'keystone.token.backends.sql.Token'
#   [token_expiration] Amount of time a token should remain valid (seconds).
#     Optional.  Defaults to 86400 (24 hours).
#   [token_format] Deprecated: Use token_provider instead.
#   [cache_dir] Directory created when token_provider is pki. Optional.
#     Defaults to /var/cache/keystone.
#   [memcache_servers] List of memcache servers/ports. Optional. Used with
#     token_driver keystone.token.backends.memcache.Token.  Defaults to false.
#   [enabled] If the keystone services should be enabled. Optional. Default to true.
#   [sql_conneciton] Url used to connect to database.
#   [idle_timeout] Timeout when db connections should be reaped.
#   [enable_pki_setup] Enable call to pki_setup.
#
#   [*public_bind_host*]
#   (optional) The IP address of the public network interface to listen on
#   Deprecates bind_host
#   Default to '0.0.0.0'.
#
#   [*admin_bind_host*]
#   (optional) The IP address of the public network interface to listen on
#   Deprecates bind_host
#   Default to '0.0.0.0'.
#
#   [*log_dir*]
#   (optional) Directory where logs should be stored
#   If set to boolean false, it will not log to any directory
#   Defaults to '/var/log/keystone'
#
# == Dependencies
#  None
#
# == Examples
#
#   class { 'keystone':
#     log_verbose => 'True',
#     admin_token => 'my_special_token',
#   }
#
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#
# == Copyright
#
# Copyright 2012 Puppetlabs Inc, unless otherwise noted.
#
class keystone(
  $admin_token,
  $package_ensure   = 'present',
  $bind_host        = false,
  $public_bind_host = '0.0.0.0',
  $admin_bind_host  = '0.0.0.0',
  $public_port      = '5000',
  $admin_port       = '35357',
  $compute_port     = '8774',
  $verbose          = false,
  $debug            = false,
  $log_dir          = '/var/log/keystone',
  $use_syslog       = false,
  $log_facility     = 'LOG_USER',
  $catalog_type     = 'sql',
  $token_format     = false,
  $token_provider   = 'keystone.token.providers.pki.Provider',
  $token_driver     = 'keystone.token.backends.sql.Token',
  $token_expiration = 86400,
  $cache_dir        = '/var/cache/keystone',
  $memcache_servers = false,
  $enabled          = true,
  $sql_connection   = 'sqlite:////var/lib/keystone/keystone.db',
  $idle_timeout     = '200',
  $enable_pki_setup = true
) {

  validate_re($catalog_type,   'template|sql')

  File['/etc/keystone/keystone.conf'] -> Keystone_config<||> ~> Service['keystone']
  Keystone_config<||> ~> Exec<| title == 'keystone-manage db_sync'|>
  Keystone_config<||> ~> Exec<| title == 'keystone-manage pki_setup'|>

  include keystone::params

  File {
    ensure  => present,
    owner   => 'keystone',
    group   => 'keystone',
    require => Package['keystone'],
    notify  => Service['keystone'],
  }

  package { 'keystone':
    ensure => $package_ensure,
    name   => $::keystone::params::package_name,
  }

  group { 'keystone':
    ensure  => present,
    system  => true,
    require => Package['keystone'],
  }

  user { 'keystone':
    ensure  => 'present',
    gid     => 'keystone',
    system  => true,
    require => Package['keystone'],
  }

  file { ['/etc/keystone', '/var/log/keystone', '/var/lib/keystone']:
    ensure  => directory,
    mode    => '0750',
  }

  file { '/etc/keystone/keystone.conf':
    mode    => '0600',
  }

  if $bind_host {
    warning('The bind_host parameter is deprecated, use public_bind_host and admin_bind_host instead.')
    $public_bind_host_real = $bind_host
    $admin_bind_host_real  = $bind_host
  } else {
    $public_bind_host_real = $public_bind_host
    $admin_bind_host_real  = $admin_bind_host
  }

  # default config
  keystone_config {
    'DEFAULT/admin_token':      value => $admin_token ,secret => true;
    'DEFAULT/public_bind_host': value => $public_bind_host_real;
    'DEFAULT/admin_bind_host':  value => $admin_bind_host_real;
    'DEFAULT/public_port':      value => $public_port;
    'DEFAULT/admin_port':       value => $admin_port;
    'DEFAULT/compute_port':     value => $compute_port;
    'DEFAULT/verbose':          value => $verbose;
    'DEFAULT/debug':            value => $debug;
  }

  # logging config
  if $log_dir {
    keystone_config {
      'DEFAULT/log_dir': value => $log_dir;
    }
  } else {
    keystone_config {
      'DEFAULT/log_dir': ensure => absent;
    }
  }

  # token driver config
  keystone_config {
    'token/driver':     value => $token_driver;
    'token/expiration': value => $token_expiration;
  }

  if($sql_connection =~ /mysql:\/\/\S+:\S+@\S+\/\S+/) {
    require 'mysql::python'
  } elsif($sql_connection =~ /postgresql:\/\/\S+:\S+@\S+\/\S+/) {

  } elsif($sql_connection =~ /sqlite:\/\//) {

  } else {
    fail("Invalid db connection ${sql_connection}")
  }

  # memcache connection config
  if $memcache_servers {
    validate_array($memcache_servers)
    keystone_config {
      'memcache/servers': value => join($memcache_servers, ',');
    }
  } else {
    keystone_config {
      'memcache/servers': ensure => absent;
    }
  }

  # db connection config
  keystone_config {
    'sql/connection':   value => $sql_connection, secret => true;
    'sql/idle_timeout': value => $idle_timeout;
  }

  # configure based on the catalog backend
  if($catalog_type == 'template') {
    keystone_config {
      'catalog/driver':
        value => 'keystone.catalog.backends.templated.TemplatedCatalog';
      'catalog/template_file':
        value => '/etc/keystone/default_catalog.templates';
    }
  } elsif($catalog_type == 'sql' ) {
    keystone_config { 'catalog/driver':
      value => ' keystone.catalog.backends.sql.Catalog'
    }
  }

  if $token_format {
    warning('token_format parameter is deprecated. Use token_provider instead.')
  }

  # remove the old format in case of an upgrade
  keystone_config { 'signing/token_format': ensure => absent }

  if ($token_format == false and $token_provider == 'keystone.token.providers.pki.Provider') or $token_format == 'PKI' {
    keystone_config { 'token/provider': value => 'keystone.token.providers.pki.Provider' }
    file { $cache_dir:
      ensure => directory,
    }

    if $enable_pki_setup {
      exec { 'keystone-manage pki_setup':
        path        => '/usr/bin',
        user        => 'keystone',
        refreshonly => true,
        creates     => '/etc/keystone/ssl/private/signing_key.pem',
        notify      => Service['keystone'],
        subscribe   => Package['keystone'],
        require     => User['keystone'],
      }
    }
  } elsif $token_format == 'UUID' {
    keystone_config { 'token/provider': value => 'keystone.token.providers.uuid.Provider' }
  } else {
    keystone_config { 'token/provider': value => $token_provider }
  }

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  service { 'keystone':
    ensure     => $service_ensure,
    name       => $::keystone::params::service_name,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
    provider   => $::keystone::params::service_provider,
  }

  if $enabled {
    include keystone::db::sync
    Class['keystone::db::sync'] ~> Service['keystone']
  }

  # Syslog configuration
  if $use_syslog {
    keystone_config {
      'DEFAULT/use_syslog':           value => true;
      'DEFAULT/syslog_log_facility':  value => $log_facility;
    }
  } else {
    keystone_config {
      'DEFAULT/use_syslog':           value => false;
    }
  }
}
