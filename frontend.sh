#!/bin/bash
source ./common.sh
CHECK_ROOT 

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabling nginx"


dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enabling nginx"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOG_FILE
systemctl start nginx 
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "Removing default content"


curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading the frontend code"
 
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Unzipping frontend code in html dir"

rm -rf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "Remove default nginx conf"

cp /$SCRIPT_DIR/nginx.conf  /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "Copying the nginx conf file "

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restarting the nginx"

PRINT_TIME
