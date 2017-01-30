#!/bin/bash

docker build -t hugodelval/lizardfs-master .
docker run -i hugodelval/lizardfs-master /run.sh "172.17.0.0\\/24"

apt-get install net-tools
