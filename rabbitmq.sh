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
echo "Please enter rabbitmq password to setup: "
read -s Rabbitmq_pass

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
    rabbitmqctl add_user roboshop $Rabbitmq_pass &>> $LOG_FILE
else 
    echo  -e "Rabbitmq user and password already set up...$Y SKIPPING $N" | tee -a $LOG_FILE 
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>> $LOG_FILE

End_time=$(date +%s)
TOTAL_TIME=$(( $End_time - $Start_time ))

echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE

