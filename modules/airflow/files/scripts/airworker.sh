#!/bin/bash

# {env} variable refers to dev|qa|prod env

source /etc/profile
sed -i 's!"FORWARDED_ALLOW_IPS", "127.0.0.1"!"FORWARDED_ALLOW_IPS", "*"!' /usr/local/lib/python3.7/site-packages/gunicorn/config.py
mv -f /opt/scripts/${env}-airflow.cfg /usr/local/airflow/airflow.cfg

# Get the values from AWS SSM Parameter Store
params=(DB_USER DB_PASS DB_NAME DB_HOST CLIENT_SECRET CLIENT_ID)
for param in "${params[@]}";
do
    sed -i "s/{"${param}"}/$(aws ssm get-parameter --name /"${env}"/airflow/"${param}" --region us-east-1| jq -r ".Parameter.Value")/g" /usr/local/airflow/airflow.cfg
done
chown -R airflow:airflow /usr/local/airflow
runuser -l airflow -c 'airflow initdb'

systemctl start airflow-worker && systemctl enable airflow-worker