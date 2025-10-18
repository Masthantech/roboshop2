#!/bin bash
source ./common.sh

CHECK_ROOT

dnf install mysql-server -y &>> $LOG_FILE
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>> $LOG_FILE
VALIDATE $? "enabling mysql server"

systemctl start mysqld  &>> $LOG_FILE
VALIDATE $? "Startinging mysql server"

mysql -h mysql.shaik.cloud -u root -pRoboShop@1 -e 'show databases;' &>> $LOG_FILE

if [ $? -ne 0 ]
then
    echo -e "Root password is not setup yet..$Y Setting up now $N" | tee -a $LOG_FILE
    mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE
    VALIDATE $? "Setting up root password"
else 
    echo -e "Root password is already setup...$Y SKIPPING $N" | tee -a $LOG_FILE
fi    

PRINT_TIME