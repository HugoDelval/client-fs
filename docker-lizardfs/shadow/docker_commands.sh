#!/bin/bash

docker build -t hugodelval/lizardfs-shadow .
docker run -i --add-host=mfsmaster:172.17.0.2 hugodelval/lizardfs-shadow bash -c "service lizardfs-master restart && bash"
