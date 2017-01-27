#!/bin/bash

docker build -t hugodelval/lizardfs-metalogger .
docker run -i --add-host=mfsmaster:172.17.0.2 hugodelval/lizardfs-metalogger bash -c "service lizardfs-metalogger restart && bash"
