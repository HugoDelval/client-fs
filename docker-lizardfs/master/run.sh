#!/bin/bash

sed -i 's/172.17.0.0\/24/'$1'/g' /etc/mfs/mfsexports.cfg
service lizardfs-master restart
bash
