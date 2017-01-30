#!/bin/bash

docker build -t hugodelval/lizardfs-shadow .
docker run -i --add-host=mfsmaster:172.17.0.2 hugodelval/lizardfs-shadow /run.sh "172.17.0.0\\/24"
