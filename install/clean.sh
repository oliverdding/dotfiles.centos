#!/bin/sh

yum -y remove docker \
    docker-ce \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine

yum -y remove tencentos-release-docker-ce
