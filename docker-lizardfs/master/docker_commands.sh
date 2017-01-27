#!/bin/bash

docker build -t hugodelval/lizardfs-master .
 docker run -i hugodelval/lizardfs-master bash -c "service lizardfs-master restart && bash"

apt-get install net-tools
