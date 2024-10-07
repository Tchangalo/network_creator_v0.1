#!/bin/bash

r=$1
a=$2

for i in $(seq 1 $1)
   do sudo qm shutdown 10100$i
      sudo qm start 10100$i 
      sleep $2
   done