#!/bin/bash -

git push origin
git push tengxun

ssh -i /Users/cooli7wa/liuqi/ecs/tengxun/woke.pem ubuntu@43.143.130.151 'cd cooli7wa.github.io && git pull && bash _posts/_tools/site_deploy.sh'