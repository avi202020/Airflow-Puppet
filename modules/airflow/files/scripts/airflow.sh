#!/bin/bash

#{env_server} in this script assumes that the server has an env variable which represents if it's a dev|qa|prod server 
pip3 install --upgrade Flask-OAuthlib
sed -i 's!"FORWARDED_ALLOW_IPS", "127.0.0.1"!"FORWARDED_ALLOW_IPS", "*"!' /usr/local/lib/python3.7/site-packages/gunicorn/config.py
if [ -d /usr/local/airflow/dags ]; then echo "dag directory is present"; else mkdir /usr/local/airflow/dags; fi
if [ -f /usr/local/airflow/airflow.cfg ]; then 
    rm -f /usr/local/airflow/airflow.cfg
    cp -rf /opt/scripts/${env_server}-airflow.cfg /usr/local/airflow/airflow.cfg
else
    cp -rf /opt/scripts/${env_server}-airflow.cfg /usr/local/airflow/airflow.cfg
fi
chown -R airflow:airflow /usr/local/airflow
if [ $AIRFLOW_HOME == '/usr/local/airflow' ]
then
    runuser -l airflow -c 'airflow initdb'
    if [ $? -eq 0 ]; then
        if [ `airflow variables -g run_env` == "dev" ]; then 
            echo "The variables are already set"; 
        else
            chown airflow:airflow /opt/scripts/dev-variables.json
            runuser -l airflow -c 'airflow variables --import /opt/scripts/dev-variables.json'
            runuser -l airflow -c 'airflow initdb'
        fi
    else
        echo "Command Succeeded"
    fi
elif [ $AIRFLOW_HOME == '/usr/local/airflowexport' ]; then
    rm -rf /usr/local/airflowexport
    export $AIRFLOW_HOME='/usr/local/airflow'
    runuser -l airflow -c 'airflow initdb'
    if [ $? -eq 0 ]; then
        if [ `airflow variables -g run_env` == "dev" ]; then 
            echo "The variables are set"; 
        else
            chown airflow:airflow /opt/scripts/dev-variables.json
            runuser -l airflow -c 'airflow variables --import /opt/scripts/dev-variables.json'
            runuser -l airflow -c 'airflow initdb'
        fi
    else
        echo "airflowexport removed and Command Succeeded"
    fi
else
    echo $AIRFLOW_HOME
fi
systemctl start airflow-scheduler && systemctl enable airflow-scheduler
systemctl start airflow-webserver && systemctl enable airflow-webserver