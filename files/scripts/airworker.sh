#!/bin/bash
#{env_server} in this script assumes that the server has an env variable which represents if it's a dev|qa|prod server
export AIRFLOW_HOME=/usr/local/airflow
source /etc/profile
airflow initdb
yes | cp -rf /opt/scripts/${env_server}-airflow.cfg /usr/local/airflow/airflow.cfg
chown -R airflow:airflow /usr/local/airflow
airflow initdb
service airflow-worker start
systemctl enable airflow-worker
systemctl start redis
systemctl enable redis