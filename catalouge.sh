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
dnf module disable nodejs -y

VALIDATE $? "disabling current Nodejs" &>> $LOGFILE

dnf module enable nodejs:18 -y

VALIDATE $? "Enabling Nodejs:18" &>> $LOGFILE

dnf install nodejs -y

VALIDATE $? "Installing Nodejs:18" &>> $LOGFILE

useradd roboshop

VALIDATE $? "Creating roboshop user" &>> $LOGFILE

mkdir /app

VALIDATE $? "Creating app directory" &>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "downloading catlouge application" &>> $LOGFILE

cd /app 

unzip /tmp/catalogue.zip

VALIDATE $? "unzipping catalouge" &>> $LOGFILE

npm install 

VALIDATE $? "installing dependences" &>> $LOGFILE

cp /users/naren/devops/shell-script/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "copying catalouge service file"

systemctl daemon-reload  &>> $LOGFILE

VALIDATE $? "catalouge daemon reload" &>> $LOGFILE

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enable catalouge"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "starting catalouge"

cp /users/naren/devops/shell-script/roboshop-shell/mongo.rep//etc/yum.repos.d/mongo.rep

VALIDATE $? "copying mongodb.repo"

dnf install mongodb-org-shell -y

VALIDATE $? "installing mongodb client"

mongo --host mongodb.daws76.space </app/schema/catalogue.js

VALIDATE $? "loading catalouge data into MongoDB"
