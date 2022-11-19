#!/bin/bash -

sudo rm -rf /var/www/cooli7wa.com
sudo cp -R /home/lighthouse/liuqi/cooli7wa.github.io/_site /var/www/cooli7wa.com

sudo service nginx restart