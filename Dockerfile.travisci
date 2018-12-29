FROM debian:buster-20181112-slim

RUN apt-get update && apt-get install -y curl zlib1g-dev libssl-dev
RUN curl -fsS -o /etc/apt/sources.list.d/d-apt.list http://master.dl.sourceforge.net/project/d-apt/files/d-apt.list
RUN apt-get update --allow-insecure-repositories && apt-get -y --allow-unauthenticated install --reinstall d-apt-keyring

RUN apt-get update && apt-get -y --allow-unauthenticated install dmd-compiler ldc dub


WORKDIR /src

COPY ./source ./source/
COPY dub.* ./

RUN dub upgrade
