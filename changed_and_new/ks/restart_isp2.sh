#!/bin/bash

r=$1
a=$2

for i in $(seq 1 $1)
   do sudo qm shutdown 20200$i
      #sleep 1
      sudo qm start 20200$i 
      sleep $2
   done