FROM golang:1.15

RUN apt-get update
RUN apt-get install python3 python3-pip -y

RUN pip3 install --upgrade pip
RUN pip3 install awscli
RUN pip3 install aws-sam-cli==1.12

WORKDIR /var/opt

EXPOSE 3003
