#!/bin/bash -

sudo bundle update
sudo jekyll build

sudo rm -rf /var/www/cooli7wa.com
sudo cp -R ./_site /var/www/cooli7wa.com
sudo chmod -R a+r /var/www/cooli7wa.com

sudo service nginx restart