#!/bin bash
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

CHECK_ROOT () {
    if [ $USERID -ne 0 ] 
    then 
        echo -e " $R ERROR...Please run this script with root access $N" | tee -a $LOG_FILE
        exit 1
    else 
        echo -e " $Y You are running the script wit root access $N" | tee -a $LOG_FILE   
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

echo  "Script started running at: $(date)" | tee -a $LOG_FILE
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

End_time=$(date +%s)

Total_time=$(( $End_time - $Start_time ))

echo -e "Script executed successfully, $Y Time taken : $Total_time Seconds $N" | tee -a $LOG_FILE