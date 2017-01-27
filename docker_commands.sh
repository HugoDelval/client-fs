#!/bin/bash

docker build -t hugodelval/lizardfs-client-stack .
docker run -i --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined --add-host=mfsmaster:172.17.0.2 hugodelval/lizardfs-client-stack /app/run.sh
