#!/bin/bash -
find ./ -name "*.md" -exec sed -i "s/author:\(.*\)/author:\\n  name:\1\\n  link: https:\/\/cooli7wa67@163.com/g" {} +
