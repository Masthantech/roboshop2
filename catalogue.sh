#!/bin bash
Start_time=$(date +%s)
USERID=$(id -u)
R="\e[31m"
g="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD
mkdir -p $LOG_FOLDER

echo  "Script started running at: $(date)" | tee -a $LOG_FILE

CHECK_ROOT () {
    if [ $USERID -ne 0 ] 
    then 
        echo -e " $R ERROR...Please run this script with root access $N" | tee -a $LOG_FILE
        exit 1
    else 
        echo -e " $Y You are running the script with root access $N" | tee -a $LOG_FILE   
    fi     
}

VALIDATE () {
    if [ $1 -ne 0 ]
    then 
        echo -e  "$2 is.... $R ERROR $N" | tee -a $LOG_FILE
        exit 1
    else 
        echo -e   "$2 is....$G SUCCESS $N" | tee -a $LOG_FILE  
    fi    
}


CHECK_ROOT 

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing nodejs"

id roboshop 
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating roboshop system user"
else
    echo -e "System user roboshop already created ... $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "Creating APP directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOG_FILE
VALIDATE $? "Downloading application code"

rm -rf /app/* &>>$LOG_FILE
cd /app 

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "Unzipping application code in app directory"

cd /app 

npm install &>>$LOG_FILE
VALIDATE $? "Installing application dependencies using npm" 

cp /$SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service  &>>$LOG_FILE

systemctl daemon-reload &>>$LOG_FILE
systemctl enable catalogue &>>$LOG_FILE
systemctl start catalogue
VALIDATE $? "Starting the catalogue service"

cp /$SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo 
dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing mongodb shell" 


STATUS=$(mongosh --host mongodb.shaik.cloud --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $STATUS -lt 0 ]
then 
    mongosh --host mongodb.shaik.cloud </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading the data into database" 
else 
    echo -e "Data is already loaded into database... $Y SKIPPING $N"
fi    


End_time=$(date +%s)

Total_time=$(( $End_time - $Start_time ))

echo -e "Script executed successfully, $Y Time taken : $Total_time Seconds $N" | tee -a $LOG_FILE






























