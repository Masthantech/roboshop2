#!/bin/bash 
source ./common.sh
app_name=shipping
ROOT_CHECK
echo "Please enter the mysql password: "
read -s mysql_pass

app_setup
mvn_setup
systemd_setup

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing mysql client"

mysql -h mysql.shaik.cloud -u root -p$mysql_pass -e 'use cities;' &>>$LOG_FILE

if [ $? -ne 0 ]
then 
    echo -e "data is not loaded into database...$Y Loading now $N"
    mysql -h mysql.shaik.cloud -uroot -p$mysql_pass < /app/db/schema.sql &>>$LOG_FILE
    mysql -h mysql.shaik.cloud -uroot -p$mysql_pass < /app/db/app-user.sql &>>$LOG_FILE
    mysql -h mysql.shaik.cloud -uroot -p$mysql_pass < /app/db/master-data.sql &>>$LOG_FILE
else 
    echo -e "data is already loaded into database...$Y SKIPPING $N"
fi


systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Re-starting shipping service"


PRINT_TIME




