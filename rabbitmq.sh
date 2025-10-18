#!/bin bash
source ./common.sh
CHECK_ROOT 

cp /$SCRIPT_DIR/rabbitmq.repo  /etc/yum.repos.d/rabbitmq.repo &>> $LOG_FILE
VALIDATE $? "Copying rabbitmq repo file" 

dnf install rabbitmq-server -y &>> $LOG_FILE
VALIDATE $? "Installing Rabbitmq server" 

 
systemctl enable rabbitmq-server &>> $LOG_FILE
systemctl start rabbitmq-server  &>> $LOG_FILE
VALIDATE $? "Starting Rabbitmq server" 

id roboshop

if [ $? -ne 0 ]
then 
    echo -e "Please enetr the rabbitmq password to setup: "
    read -s Rabbitmq_pass
    rabbitmqctl add_user roboshop $Rabbitmq_pass &>> $LOG_FILE
else 
    echo  -e "Rabbitmq user and password already set up...$Y SKIPPING $N" | tee -a $LOG_FILE 
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>> $LOG_FILE

PRINT_TIME
