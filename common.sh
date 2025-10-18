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

app_setup () {
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

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>> $LOG_FILE
    VALIDATE $? "Downloading application code"

    rm -rf /app/* &>>$LOG_FILE
    cd /app 

    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "Unzipping application code in app directory"

}


nodejs_setup () {
    
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disabling nodejs"

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enabling nodejs"

    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installing nodejs"

    npm install &>>$LOG_FILE
    VALIDATE $? "Installing application dependencies using npm"

}

systemd_setup () {

    cp /$SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service  &>>$LOG_FILE
    VALIDATE $? "Copying $app_name service"

    systemctl daemon-reload &>>$LOG_FILE
    systemctl enable $app_name &>>$LOG_FILE
    systemctl start $app_name
    VALIDATE $? "Starting the $app_name service"
}

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



PRINT_TIME () {
    End_time=$(date +%s)

    Time_taken=$(($End_time - $Start_time))
    echo -e "Script executed successfully, $Y Time taken is: $Time_taken Seconds $N"
}