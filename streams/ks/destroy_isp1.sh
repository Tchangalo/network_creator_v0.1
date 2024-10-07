#!/bin/bash

r=$1

for i in $(seq 1 $1)
  do sudo qm stop 10100$i 
     sudo qm destroy 10100$i
  done