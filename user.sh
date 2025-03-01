
#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
    }

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi
dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "disabling current Nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling Nodejs:18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing Nodejs:18"

useradd roboshop  &>> $LOGFILE

VALIDATE $? "roboshop user creation"

mkdir /app &>> $LOGFILE

VALIDATE $? "Creating app directory"

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "downloading user application"

cd /app 

url -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "downloading catlouge application"

cd /app 

unzip /tmp/user.zip &>> $LOGFILE

VALIDATE $? "unzipping user"

npm install &>> $LOGFILE

VALIDATE $? "installing dependences"

cp /users/naren/devops/shell-script/roboshop-shell/user.service//etc/systemd/system/user.service

systemctl daemon-reload  &>> $LOGFILE

VALIDATE $? "user daemon reload"

systemctl enable user &>> $LOGFILE

VALIDATE $? "enable user"

systemctl start user &>> $LOGFILE

VALIDATE $? "starting user"

cp /users/naren/devops/shell-script/roboshop-shell/mongo.rep//etc/yum.repos.d/mongo.rep

VALIDATE $? "copying mongodb.repo"

dnf install mongodb-org-shell -y

VALIDATE $? "installing mongodb client"

mongo --host mongodb.daws76.space </app/schema/user.js

VALIDATE $? "loading user data into MongoDB"
