class airflow_server {

  user { 'airflow':
    ensure     => 'present',
    comment    => 'airflow',
    home       => '/usr/local/airflow',
    shell      => '/bin/bash',
    managehome => true,
  }

  -> class { 'common': }
  -> class { 'airflow': }

  class { 'nginx':
    confd_purge          => true,
    server_purge         => true,
    worker_processes     => 'auto',
    worker_rlimit_nofile => 64000,
    worker_connections   => 20000,
    server_tokens        => 'off',
    gzip                 => 'on',
    gzip_comp_level      => '6',
    gzip_proxied         => 'any',
    gzip_vary            => 'on',
    gzip_types           => [
      'text/plain',
      'text/css',
      'text/xml',
      'text/javascript',
      'application/x-javascript',
      'application/xml',
      'application/json',
      'application/javascript',
      'image/svg+xml',
    ],
    log_format           => {
      'syslog'  => '[$time_iso8601] $http_x_request_id $remote_addr $status $request_length $body_bytes_sent $request_time $request_method $http_host $request_uri $server_protocol $http_content_type $http_referer "$http_user_agent"',
      'fluentd' => '{ "@timestamp": "$time_iso8601", "@fields": { "request_id": "$http_x_request_id", "remote_addr": "$remote_addr", "status": "$status", "request_length": "$request_length", "body_bytes_sent": "$body_bytes_sent", "request_time": "$request_time", "request_method": "$request_method", "http_host": "$http_host", "request_uri": "$request_uri", "server_protocol": "$server_protocol", "http_content_type": "$http_content_type", "http_referrer": "$http_referer", "http_user_agent": "$http_user_agent" } }'
    },
    nginx_error_log      => 'syslog:server=127.0.0.1,facility=local6,tag=nginx,severity=error',
    http_access_log      => 'syslog:server=127.0.0.1,facility=local6,tag=nginx,severity=info',
    http_format_log      => 'syslog',
    http_cfg_append      => {
        'set_real_ip_from'            => '0.0.0.0/0',
        'real_ip_header'              => 'Fastly-Client-IP',
        'large_client_header_buffers' => '4 16k',
    },
  }

  file {
    '/var/log/airflow':
      ensure => 'directory',
      mode   => '0755',
      owner  => 'airflow',
      group  => 'airflow';
    '/var/log/nginx/access.log':
      ensure  => absent,
      require => Package['nginx'];
    '/var/log/nginx/error.log':
      ensure  => absent,
      require => Package['nginx'];
    '/etc/rsyslog.d/30-nginx.conf':
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/common/nginx-rsyslog.conf';
    '/etc/rsyslog.d/30-airflow-webserver.conf':
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/airflow/airflow-webserver-rsyslog.conf';
  }

  logrotate::rule { 'nginx':
    path       => '/var/log/nginx/*.log',
    postrotate => '/bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true',
    require    => Package['nginx'],
  }
  logrotate::rule { 'airflow-webserver':
    path       => ['/var/log/airflow/webserver.log'],
    postrotate => '/bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true',
    require    => File['/var/log/airflow'],
  }

  nginx::resource::upstream { 'backend':
    ensure  => present,
    members => {
      '127.0.0.1:8080' => {
        server => '127.0.0.1',
        port   => 8080,
      },
    },
  }
}

class dev_server {
  class { 'airflow_server': }

  nginx::resource::server { 'default':
    proxy                => 'http://backend',
    server_name          => ['_'],
    index_files          => [],
    server_cfg_prepend   => {
      'error_page 403' => '/403',
      'error_page 404' => '/404',
      'error_page 500' => '/timeout.html',
      'error_page 503' => '/timeout.html',
    },
    location_cfg_prepend => {
      proxy_http_version => '1.1',
      proxy_redirect     => 'off',
      proxy_set_header   => {
        # https://www.nginx.com/blog/mitigating-the-httpoxy-vulnerability-with-nginx/
        'Proxy'      => '""',
        'Upgrade'    => '$http_upgrade',
        'Connection' =>  '"upgrade"',
      }
    },
    error_log            => absent,
    access_log           => absent,
  }
}
