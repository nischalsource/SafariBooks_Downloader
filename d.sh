#!/bin/bash

#Prints out help on how to use this script
function  echoHelp () {
cat <<-END
Usage:
------
   -h | --help
     Display this help
   -c | --cookie
     Add the absolute filesystem location to the Netscape format cookie.txt file
   -d | --dir
     Specify the name of the directory this script must create from this level to download 
   -u | --url
     Specify the complete URI to download in the following URI format:  protocol://domain/directory
END
}


#Begin
clear;

#Checks for Parameters
printf "STEP 1: Check for Parameters\n\n"
if [ $# -eq 0 ]; then
    printf "No arguments specified. Try -h for help"
    exit;
fi
       


#Processes Parameters
while [ ! $# -eq 0 ]
do
    case $1 in
        -c | --cookie)
            cookie=$2
	    printf "The cookie value is:\t\t%s\n" $cookie
            shift 2 ;;
        -d | --dir)
	    dir=$2
            printf "The directory value is:\t\t%s\n" $dir
            shift 2 ;;
        -u | --url)
            url=$2
	    printf "The url value is:\t\t%s\n" $url
            shift 2 ;;
        -h | \? | --help)
            echoHelp
            exit
            ;;
    esac
done

#Check Parameters have been successfully set
if ${dir+"false"}; then
   echo "Error: Please Specify the name of the directory this script must create from this level to download";
   exit;
elif ${cookie+"false"}; then
   echo "Error: Please Specify the absolute filesystem location to the Netscape format cookie.txt file"
   exit;
elif ${url+"false"}; then
   echo "Error: Please specify the complete URI to download in the following URI format:  protocol://domain/directory"
   exit;
elif  [ ! -f $cookie ]; then
   echo "Error: Please check the path to the specified Netscape cookie.txt file"
   exit;
fi



# Set private members
domain="https://www.safaribooksonline.com"
domainLength=${#domain}
dir_separator="/"
dirLength=$((${#dir} + ${#dir_separator}))
includePath3=${url:$domainLength}
includePath2=${includePath3%$dir_separator}
includePath=${includePath2},/static
printf "The includePath is:\t\t%s\n" $includePath




#Check if Cookie is Valid
printf "\nSTEP 2: Check login Cookie is Valid\n"

count=$(wget -SO- --header='Host: www.safaribooksonline.com' --header='User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0' --header='Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' --header='Accept-Language: en-US,en;q=0.5' --header='Content-Type: application/x-www-form-urlencoded' --load-cookies /home/shiva/Documents/ebooks/downloads/cookies.txt https://www.safaribooksonline.com/home 2>&1 1>/dev/null | grep -c 'logged_in=y');

if (($count >= 1)) ; then
   printf "Cookie is valid. Login Successful!\n";
else
   printf "\nCookie is not valid.\n";
   printf "Would you still like to continue? Y or N";
fi



#Construct Container Directory
mkdir $dir
cd $dir


#Main Download in a recursive way
printf "\nSTEP 3: Beginning Main Download\n\n"

wget -nv -k -r --no-directories -I $includePath --header='Host: www.safaribooksonline.com' --header='User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0' --header='Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' --header='Accept-Language: en-US,en;q=0.5' --header='Content-Type: application/x-www-form-urlencoded' --load-cookies $cookie $url


#Redownload all CSS
printf "\nSTEP 4: Redownloading and Uncompressing all .css Files\n\n"

for file in *.css;
do
wget -nv -O- --header='Accept-Encoding: gzip,deflate,br' --header='Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' --header='Accept-Language: en-US,en;q=0.5' --header='Content-Type: application/x-www-form-urlencoded' https://www.safaribooksonline.com/static/CACHE/css/$file | gunzip > $file
done;

#Replace xhtml file extension with html file extension
xhtmlCount=$(ls -1 *.xhtml 2>/dev/null | wc -l);

if (($xhtmlCount >= 1)) ; then
printf "\nSTEP 5: Replacing .xhtml extension with .html\n\n"

for xhtmlFile in *.xhtml; 
do 
mv $xhtmlFile ${xhtmlFile: 0: $((${#xhtmlFile} -6))}.html; 
done;

#Replace  all in-file xhtml links with html links
printf "\nSTEP 6: Replacing all in-file .xhtml links with .html\n\n"
for htmlFile in *.html
do
sed -i s/xhtml/html/g $htmlFile
done;
fi


printf "\n\nEND\n\n"
