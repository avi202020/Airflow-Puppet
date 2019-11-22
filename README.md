# Airflow-1.10.6
Puppet module for installing Apache-Airflow v1.10.6

I use this module to create airflow cluster.

## How-To:

- Use packer to build the AMI
- Use puppet-masterless provisioner
- Create airflow master node AMI which runs webserver and scheduler services
- Create airflow worker node AMI which runs only worker service
- Make sure the master node doesn't scale, if it does, problems might occur because of multiple scheduler running
- Use the userdata in CFT template to execute the init scripts.

## To-DO:
- Update the CFT template



