#!/bin/bash

docker build -t hugodelval/lizardfs-admin .
docker run -i --add-host="mfsmaster:172.17.0.2" hugodelval/lizardfs-admin /bin/bash
