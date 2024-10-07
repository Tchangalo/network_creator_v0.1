#!/bin/bash

git init
git branch -m main
git add .
git config --global user.email "tchangalo@proton.me"
git config --global user.name "Tchangalo"
git commit -m "Initial commit"
git remote add origin https://github.com/Tchangalo/network_creator_v0.1.git
git push -u origin main
git pull origin main --rebase
git push -u origin main
