#!/bin/bash -


sudo apt-get update
sudo apt install -y gem ruby nodejs ruby-dev jekyll

sudo gem install bundler:2.3.6

sudo bundle install
sudo bundle update

