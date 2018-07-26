class Airflow-1.9.0 {

  file { '/etc/profile.d/airflow.sh':
    content => 'export AIRFLOW_HOME=/usr/local/airflow',
    ensure  => 'present'
  }

  -> exec { 'prerequisites':
    command     => '/bin/yum install -y python-pip python-devel redis psutil gcc gcc-c++ libffi-devel mariadb-devel git wget unzip postgresql',
  }

  -> exec { 'upgrade_pip':
    command => '/bin/pip install pip==9.0.3',
  }

  -> exec { 'dependencies':
    command => '/bin/pip install redis flask-bcrypt awscli notebook boto3 MySQL-python psycopg2-binary celery[redis] cryptography Flask-Caching queries flask-oauthlib',
  }

  -> exec { 'downgrade_markupsafe':
    command => '/bin/pip install markupsafe==0.23',
  }

  -> exec { 'sqlalchemy':
    command => "/bin/pip install 'sqlalchemy<1.2'",
  }

  -> exec { 'Airflow installation':
    command => '/bin/pip install apache-airflow[all]',
  }

  -> file { '/etc/sysconfig/airflow':
    path   => '/etc/sysconfig/airflow',
    source => 'puppet:///modules/Airflow-1.9.0/airflow',
  }

  -> file { '/etc/systemd/system/airflow-flower.service':
    path   => '/etc/systemd/system/airflow-flower.service',
    source => 'puppet:///modules/Airflow-1.9.0/airflow-flower.service',
  }

  -> file { '/etc/systemd/system/airflow-scheduler.service':
    path   => '/etc/systemd/system/airflow-scheduler.service',
    source => 'puppet:///modules/Airflow-1.9.0/airflow-scheduler.service',
  }

  -> file { '/etc/systemd/system/airflow-webserver.service':
    path   => '/etc/systemd/system/airflow-webserver.service',
    source => 'puppet:///modules/Airflow-1.9.0/airflow-webserver.service',
  }

  -> file { '/etc/systemd/system/airflow-worker.service':
    path   => '/etc/systemd/system/airflow-worker.service',
    source => 'puppet:///modules/Airflow-1.9.0/airflow-worker.service',
  }

  -> file { '/opt/scripts':
    ensure => directory,
    source => 'puppet:///modules/Airflow-1.9.0/scripts',
    recurse => true,
  }
}