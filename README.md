# SafariBooks_Downloader
a linux shell script I wrote that uses a valid login cookie in Netscape format to download an entire book from http://safaribooksonline.com

##Usage:  
--------  
    -h | --help  
     Display this help  
    -c | --cookie
     Add the absolute filesystem location to the Netscape format cookie.txt file
    -d | --dir  
     Specify the name of the directory this script must create from this level to download   
    -u | --url  
     Specify the complete URI to download in the following URI format:  protocol://domain/directory  
     -f | --file
     Specify a txt file with one URI per line     

##Example
---------  

./d.sh --cookie /full/path/NetscapeCookieFormat.txt --dir DownloadFolderName --url https://www.safaribooksonline.com/library/view/creating-a-data-driven/9781491916902
