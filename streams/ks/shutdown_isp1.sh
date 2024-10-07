#!/bin/bash

r=$1

for i in $(seq 1 $1)
  do sudo qm shutdown 10100$i
  done