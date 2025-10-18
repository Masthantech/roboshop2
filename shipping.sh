#!/bin/bash 
Start_time=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOG_FOLDER 

echo -e "script started running at: $(date)" | tee -a $LOG_FILE

ROOT_CHECK () {
    if [ $USERID -ne 0 ]
    then 
        echo -e "$R ERROR...Please run the script with root access$N" | tee -a $LOG_FILE
        exit 1 
    else  
        echo -e " $Y You are running the script with root access $N" | tee -a $LOG_FILE
    fi    
}

VALIDATE () {
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 is...$R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else 
        echo -e  "$2 is....$G SUCCESS $N" | tee -a $LOG_FILE
    fi    
}

ROOT_CHECK

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Installing maven"

id roboshop 

if [ $? -ne 0 ]
then 
    echo -e "System user roboshop is not created yet...$Y Creating now$N" | tee -a $LOG_FILE
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Creating system user for application"
else 
    echo -e "System user is already created...$Y SKIPPING $N"    | tee -a $LOG_FILE
fi

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Creating APP Directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
VALIDATE $? "Downloading the application code"

rm -rf /app/* &>>$LOG_FILE

cd /app

unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "Unzipping code in app directory"

cd /app 

mvn clean package &>>$LOG_FILE
VALIDATE $? "Installing the dependencies using mvn tool"

mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
VALIDATE $? "moving jar files to app dir"

cp /$SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service  &>>$LOG_FILE
VALIDATE $? "copying service file to etc/systemd/system folder"

systemctl daemon-reload 
systemctl enable shipping 
systemctl start shipping &>>$LOG_FILE
VALIDATE $? "Starting shipping service"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing mysql client"

mysql -h mysql.shaik.cloud -u root -pRoboShop@1 -e 'use cities;' &>>$LOG_FILE

if [ $? -ne 0 ]
then 
    echo -e "data is not loaded into database...$Y Loading now $N"
    mysql -h mysql.shaik.cloud -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
    mysql -h mysql.shaik.cloud -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOG_FILE
    mysql -h mysql.shaik.cloud -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
else 
    echo -e "data is already loaded into database...$Y SKIPPING $N"
fi


systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Re-starting shipping service"


End_time=$(date +%s)

Total_time=$(( $End_time - $Start_time ))

echo -e "Script executed successfully, $Y Time taken : $Total_time Seconds $N" | tee -a $LOG_FILE





