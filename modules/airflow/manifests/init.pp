class airflow {

  package {
    [ 'sqlite-devel', 'cyrus-sasl-devel.x86_64', 'redis', 'gcc', 'gcc-c++', 'libffi-devel', 'postgresql', 'yum-utils', 'python3', 'python3-pip', 'python3-devel', 'mysql', 'mysql-devel' ]:
      ensure  => installed,
      require => Package['epel-release']; 
  }

  exec {
    'python_packages':
      cwd     => '/tmp',
      command => 'pip3 install --upgrade sqlalchemy cryptography glob2 configparser awscli botocore Cython pytz pyOpenSSL ndg-httpsclient pyasn1 Flask-YAMLConfig requests cmake redis pymongo mailchimp3 pytrends flask-bcrypt notebook psycopg2-binary celery[redis] cryptography Flask-Caching queries flask-oauthlib Flask-OAuthLib mysqlclient mangopaysdk',
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin';
    'Airflow_Install':
      cwd     => '/tmp',
      command => 'pip3 install -U apache-airflow[postgres,databricks,s3,async,celery,crypto,devel,ldap,mysql,password,redis,slack,ssh,crypto,jdbc]==1.10.6',
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin';
  }

  file {
    '/etc/profile.d/airflow.sh':
      ensure  => present,
      content => "export AIRFLOW_HOME='/usr/local/airflow'";
    '/etc/profile.d/airflowdags.sh':
      ensure  => present,
      content => "export PYTHONPATH='/usr/local/airflow/dags'";
    '/etc/sysconfig/airflow':
      ensure => 'file',
      mode   => '0644',
      owner  => 'root',
      group  => 'root',
      source => 'puppet:///modules/aetn_airflow/airflow';
    '/etc/systemd/system/airflow-scheduler.service':
      ensure => 'file',
      mode   => '0644',
      owner  => 'root',
      group  => 'root',
      source => 'puppet:///modules/aetn_airflow/airflow-scheduler.service';
    '/etc/systemd/system/airflow-webserver.service':
      ensure => 'file',
      mode   => '0644',
      owner  => 'root',
      group  => 'root',
      source => 'puppet:///modules/aetn_airflow/airflow-webserver.service';
    '/etc/systemd/system/airflow-worker.service':
      ensure => 'file',
      mode   => '0644',
      owner  => 'root',
      group  => 'root',
      source => 'puppet:///modules/aetn_airflow/airflow-worker.service';
    '/opt/scripts':
      ensure => 'directory',
      mode   => '0755',
      owner  => 'root',
      group  => 'root',
      recurse => true,
      source => 'puppet:///modules/aetn_airflow/scripts';
  }
}
