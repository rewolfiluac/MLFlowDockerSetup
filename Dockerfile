FROM ubuntu:22.04

ARG DEBIAN_FRONTEND="noninteractive"
RUN apt update && apt upgrade -y \
&&  apt install -y python3-pip python3.10 python3.10-dev \
&&  apt install -y default-libmysqlclient-dev pkg-config \
# clean up image
&&  apt clean \
&&  rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN pip3 install mlflow mysqlclient sqlalchemy boto3
RUN mkdir -p /mlflow
WORKDIR /mlflow
