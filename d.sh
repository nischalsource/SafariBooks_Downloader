#!/bin/bash

#SET PRIVATE MEMBERS 1
dir_separator="/"
alternate="_alternate"
domain="https://www.safaribooksonline.com"
domainHome="https://www.safaribooksonline.com/home"
domainLibraryView="https://www.safaribooksonline.com/library/view"$dir_separator
domainStaticFilesLocation="/static"
domainLength=${#domain}
domainLibraryViewLength=${#domainLibraryView}




#Prints out help on how to use this script
function  echoHelp () {
cat <<-END
Usage:
------
   -h | --help
     Display this help
   -c | --cookie
     Specify the absolute filesystem location to the Netscape format cookie.txt file
   -d | --dir
     Specify the name of the directory this script must create from this level to download 
   -u | --url
     Specify the complete URI to download in the following URI format:  protocol://domain/directory
   -f | --file
     Specify the absolute filesystem location of a list of url's to download in the form of a .txt file 
END
}


#Begin
if [ -z $recursive]; then
clear;
fi

#Checks for Parameters
printf "STEP 1: Check for Parameters\n\n"
if [ $# -eq 0 ]; then
    printf "No arguments specified. Try -h for help\n\n"
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
        -f | --file)
           file=$2
           printf "The file value is:\t\t%s\n" $file
           shift 2 ;;
        -r | --recursive)
           recursive=true
           printf "The recursive value is:\t\t%s\n" $recursive
	   shift 1 ;;
        -h | \? | --help)
           echoHelp
           exit;
    esac
done


#Check Required Parameters
if [ -z $recursive ]; then
if [ -n $file ]; then
  if [ -z $cookie ]; then
   printf "Error: Please Specify the absolute filesystem location to the Netscape format cookie.txt file\n\n";
   exit;
  else
    if [ -f $file ]; then
     export file=$file;
     while read
      do
       if [ ${#REPLY} -ge 0 ]; then
        #return everything after the last slash 
        #http://landoflinux.com/linux_bash_scripting_substring_tests.html
        ReplyWithoutSlash=${REPLY##*/}
        #total url length minus length of everything after the last slash
        lastSlashPos=$((${#REPLY} - ${#ReplyWithoutSlash}))
        dirNameLength=$(($lastSlashPos - $domainLibraryViewLength))
        dir=${REPLY: $domainLibraryViewLength: $dirNameLength};
        $bash ./d.sh --cookie $cookie --url $REPLY --dir $dir --recursive
       else
        echo "There exist nothing at this line"
       fi
      done < "$file"
    else
     printf "Error: Cannot locate the file list you provided\n\n";
     exit;
    fi
  fi
fi 
fi

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



# SET PRIVATE MEMBERS 2
dirLength=$((${#dir} + ${#dir_separator}))
includePath3=${url:$domainLength}
includePath2=${includePath3%$dir_separator}
includePath=${includePath2}$domainStaticFilesLocation

printf "The includePath is:\t\t%s\n" $includePath



#Check if Cookie is Valid
printf "\nSTEP 2: Check login Cookie is Valid\n"

count=$(wget -SO- --header='Host: www.safaribooksonline.com' --header='User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0' --header='Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' --header='Accept-Language: en-US,en;q=0.5' --header='Content-Type: application/x-www-form-urlencoded' --load-cookies $cookie $domainHome 2>&1 1>/dev/null | grep -c 'logged_in=y');

if (($count >= 1)) ; then
   printf "Cookie is valid. Login Successful!\n";
else
   printf "\nCookie is not valid.\n";
   exit;
   printf "Would you still like to continue? Y or N";
fi



#Construct Container Directory
if [ ! -d $dir ]; then
  mkdir $dir
  cd $dir
else
  mkdir $dir$alternate
  cd $dir$alternate
fi


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
