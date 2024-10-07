#!/bin/bash

r=$1

for i in $(seq 1 $1)
  do sudo qm stop 20200$i 
     sudo qm destroy 20200$i
  done