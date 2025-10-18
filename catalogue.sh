source ./common.sh
app_name=catalogue
CHECK_ROOT 
app_setup
nodejs_setup
systemd_setup


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

PRINT_TIME





























