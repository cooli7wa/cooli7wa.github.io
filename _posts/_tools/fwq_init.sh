#!/bin/bash -


sudo apt-get update
sudo apt install -y gem ruby nodejs ruby-dev 

sudo gem install bundler:2.3.6
sudo gem install jekyll

sudo bundle install
sudo bundle update

