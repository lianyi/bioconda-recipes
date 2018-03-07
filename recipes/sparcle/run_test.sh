#!/bin/bash


echo -n 'Testing binary '
rpsbproc
exit_status=$?
if [ $exit_status -eq 255 ]; then
    exit 0
fi
exit -1
