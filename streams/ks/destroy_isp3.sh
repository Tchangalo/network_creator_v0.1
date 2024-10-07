#!/bin/bash

r=$1

for i in $(seq 1 $1)
  do sudo qm stop 30300$i 
     sudo qm destroy 30300$i
  done