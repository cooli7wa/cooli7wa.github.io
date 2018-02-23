#!/bin/bash -

# $1: origin file name
if [ -z $1 ];then
	echo "please input file name as \$1"
	exit 1
fi

# collect title & categories
echo "please input \"date:title:categories\":"
echo "(such as: 2018-02-22:sample:study)"
read input
date=${input%%:*}
title=`echo $input | cut -d ':' -f 2`
categories=${input##*:}
echo ""
echo "======================="
echo "date: $date"
echo "title: $title"
echo "categories: $categories"
echo "======================="
echo ""

# copy file as new name
new_file_name="$date-`echo $title | tr ' ' '_'`.md"
cp $1 $new_file_name
echo "cp file as $new_file_name ... done"

# deal image
sed -i 's:!\[.*\](:&{{site.baseurl}}/images/md/:g' $new_file_name
sed -i 's:<img src=":&{{site.baseurl}}/images/md/:g' $new_file_name
echo "deal image ... done"

# deal mathjax
sed -i 1'i <script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>\n' $new_file_name
echo "deal mathjax ... done"

# deal header
sed -i 1"i \
---\n\
layout: post\n\
title: $title\n\
description:\n\
categories: $categories\n\
author: cooli7wa\n\
---\
" $new_file_name
echo "deal header ... done"

# del old file
rm $1
echo "del old file ... done"

echo -e "\033[032mdone\033[0m"
