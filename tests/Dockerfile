FROM ubuntu:latest

WORKDIR /work


# ARG secret
# ENV secret=secret

RUN apt-get update -y \
    && apt-get install -y python3-pip git libkrb5-dev

RUN pip3 install --upgrade pip \
    && pip3 install --upgrade pycodestyle

