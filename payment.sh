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

dnf install python3 gcc python3-devel -y &>> $LOG_FILE
VALIDATE $? "Installing python runtime"

id roboshop 

if [ $? -ne 0 ]
then
    echo -e "System user is not created yet...$Y creating now $N" | tee -a $LOG_FILE
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOG_FILE
    VALIDATE $? "Creating the system user"
else
    echo -e "system user is already created...$Y SKIPPING $N"   
fi 


mkdir -p /app

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>> $LOG_FILE
VALIDATE $? "Downloading the application code"

rm -rf /app/*  &>> $LOG_FILE
cd /app 

unzip /tmp/payment.zip &>> $LOG_FILE
VALIDATE $? "Unzipping the application code in /app dir"

cd /app

pip3 install -r requirements.txt &>> $LOG_FILE
VALIDATE $? "Installing the dependencies using pip tool"

cp /$SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>> $LOG_FILE
VALIDATE $? "Copying the service file"

systemctl daemon-reload &>> $LOG_FILE
systemctl enable payment 
systemctl start payment &>> $LOG_FILE
VALIDATE $? "Starting the Payment service"

End_time=$(date +%s)

Time_taken=$(( $End_time - $Start_time ))

echo -e "Script exection completed successfully, $Y time taken: $Time_taken seconds $N" | tee -a $LOG_FILE


