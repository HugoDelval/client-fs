#!/bin/bash

docker build -t hugodelval/lizardfs-chunkserver .
docker run -i --add-host=mfsmaster:172.17.0.2 hugodelval/lizardfs-chunkserver bash -c "service lizardfs-chunkserver restart && bash"
