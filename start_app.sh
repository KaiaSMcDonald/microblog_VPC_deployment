#!/bin/bash 

#Clone the Github repository 
#Install the application dependencies from the requirements.txt
#Install gunicorn, pymysql, cryptography 
#Set environmental variables, flask commands, a gunicorn command that will serve the application in the background 

#Update necessary system dependencies
sudo apt update && sudo apt install fontconfig openjdk-17-jre software-properties-common && sudo add-apt-repository ppa:deadsnakes/ppa && sudo apt install python3.7 python3.7-venv

# Clone the Github repository 
REPO_URL= https://github.com/KaiaSMcDonald/microblog_VPC_deployment.git
Git clone "$REPO_URL" microblog_VPC_deployment
Cd microblog_VPC_deployment 

#Install the application dependencies from the requirements.txt
Pip install -r requirements.txt
Pip install gunicorn pymysql cryptography  #installing gunicorn, pymysql, cryptography

#Set environmental variables 
Export FLASK_APP=microblog.py

#Set flask commands 
flask translate compile
flask db upgrade

#Start gunicorn in the background
gunicorn -b :5000 -w 4 microblog:app --daemon

