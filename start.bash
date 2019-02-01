#!/bin/bash
echo "starting ..."
/usr/sbin/sshd
if [ $# -eq 0 ] ; then
  echo "interactive mode"
  bash -l # interactive session
else
  echo "command mode"
  $@
fi
echo "stoping ..."
