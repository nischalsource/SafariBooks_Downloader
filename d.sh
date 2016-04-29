#!/bin/bash

domain="https://www.safaribooksonline.com"
domainLength=${#domain}

cookie=$1

dir=$2
dir_separator="/"
dirLength=$((${#dir} + ${#dir_separator}))

url=$3

includePath3=${url:$domainLength}
includePath2=${includePath3%$dir_separator}
includePath=${includePath2},/static

echo $cookie
echo $dir
echo $url
echo $includePath

#Construct Container Directory
mkdir $dir
cd $dir

#Main Download
wget -k -r --no-directories -I $includePath --header='Host: www.safaribooksonline.com' --header='User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0' --header='Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' --header='Accept-Language: en-US,en;q=0.5' --header='Content-Type: application/x-www-form-urlencoded' --load-cookies $cookie $url

for file in *.css;
do
echo $file
#Redownload all CSS
wget -O- --header='Accept-Encoding: gzip,deflate,br' --header='Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' --header='Accept-Language: en-US,en;q=0.5' --header='Content-Type: application/x-www-form-urlencoded' https://www.safaribooksonline.com/static/CACHE/css/$file | gunzip > $file
done;

#Replace xhtml file extension with html file extension
for xhtmlFile in *.xhtml; 
do 
mv $xhtmlFile ${xhtmlFile: 0: $((${#xhtmlFile} -6))}.html; 
done;

#Replace  all in file xhtml links with html links
for htmlFile in *.html
do
sed -i s/xhtml/html/g $htmlFile
done;
