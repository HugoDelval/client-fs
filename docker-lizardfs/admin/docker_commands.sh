#!/bin/bash

docker build -t admin .
docker run -i --add-host="mfsmaster:172.17.0.2" admin /bin/bash
