source ./common.sh
CHECK_ROOT 

cp /$SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOG_FILE
VALIDATE $? "Copying mongo repo"

dnf install mongodb-org -y &>> $LOG_FILE
VALIDATE $? "Installing MongoDB"

systemctl enable mongod &>> $LOG_FILE
systemctl start mongod  &>> $LOG_FILE
VALIDATE $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOG_FILE
VALIDATE $? "Editing  mongod conf file to allow remote connections"

systemctl restart mongod &>> $LOG_FILE
VALIDATE $? "Restarting MongoDB"

PRINT_TIME


