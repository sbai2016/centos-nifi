#!/bin/bash
#/usr/sbin/sshd

bash -c "/nifi-1.5.0/bin/nifi.sh start"

tail -f /dev/null 