#!/bin/bash

mfsmount /mnt/lizardfs
cd /app
echo "***** Content of shared folder(s) *****"
echo "`ls -lRa /mnt/lizardfs`"
ls -lRa /mnt/lizardfs
echo
echo "***** Executing script *****"
echo "`stack exec client-fs-exe && bash`"
stack exec client-fs-exe && bash
echo
echo "***** Content of shared folder(s) *****"
echo "`ls -lRa /mnt/lizardfs`"
ls -lRa /mnt/lizardfs
echo
echo "You now have a bash console:"
/bin/bash
