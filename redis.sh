#!/bin/bash

source ./common.sh
CHECK_ROOT 

dnf module disable redis -y &>> $LOG_FILE
VALIDATE $? "Disabling redis"

dnf module enable redis:7 -y &>> $LOG_FILE
VALIDATE $? "Enabling redis"

dnf install redis -y &>> $LOG_FILE
VALIDATE $? "Installing redis"

sed -i -e s/127.0.0.1/0.0.0.0/g -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Edited redis.conf to accept remote connections"

systemctl enable redis &>> $LOG_FILE
VALIDATE $? "Enabling redis"


systemctl start redis  &>> $LOG_FILE
VALIDATE $? "Starting redis"

PRINT_TIME