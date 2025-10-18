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

End_time=$(date +%s)

Total_time=$(( $End_time - $Start_time ))

echo -e "Script executed successfully, $Y Time taken : $Total_time Seconds $N" | tee -a $LOG_FILE
