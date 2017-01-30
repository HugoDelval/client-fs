#!/bin/bash

docker build -t hugodelval/lizardfs-cgi .
docker run -d -p 9425:9425 --add-host="mfsmaster:172.17.0.2" hugodelval/lizardfs-cgi