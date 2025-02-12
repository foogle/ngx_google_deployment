#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   System Required:  Debian or Ubuntu (32bit/64bit)
#   Description:  Install Proxy for Google by Nginx
#   Author: Arno <blogfeng@blogfeng.com>
#   Intro:  https://github.com/arnofeng/ngx_google_deployment
#===============================================================================================
clear
echo "
#This shell is for Nginx_proxy_google on Debian
#This project is on url:https://github.com/arnofeng/ngx_google_deployment
#Thank you for any feedback to me:blogfeng@blogfeng.com
"
echo -n "To be sure your system is Debian/Ubuntu,please enter 'y/yes' to continue: "  
read key
if [ $key = "yes" ]||[ $key = "y" ];then
	echo -n "Set your domain for google search: " 
    read key1
    DOMAIN1=$key1
    echo -n "Set your domain for google scholar: "
    read key2
    DOMAIN2=$key2
    if [ ! $DOMAIN1 ]||[ ! $DOMAIN2 ]||[ $DOMAIN1 = $DOMAIN2 ];then
    	echo "Two domains should not be null OR the same! Error happens!"
    	exit 1
    else
    	echo "your google search domain is $DOMAIN1"
    	echo "your google scholar domain is $DOMAIN2"
    	echo -n "Enter any key to continue ... "
        read goodmood
    	echo 'Start installing!' 	
    fi
    
else
	exit 1
fi
#1.update  system
apt-get update
if [ $? -eq 0 ]; then
	echo "update success"
else
	apt-get update
fi
#2.install  dependency
apt-get install -y libpcre3 libpcre3-dev
if [ $? -eq 0 ]; then
	echo "libpcre3 libpcre3-dev installed"
else
	apt-get install -y libpcre3 libpcre3-dev
fi
apt-get install -y zlib1g zlib1g-dev openssl libssl-dev
if [ $? -eq 0 ]; then
	echo "zlib1g zlib1g-dev openssl libssl-dev installed"
else
	apt-get install -y zlib1g zlib1g-dev openssl libssl-dev
fi
apt-get install -y gcc g++ make automake
if [ $? -eq 0 ]; then
	echo "gcc g++ make automake installed"
else
	apt-get install -y gcc g++ make automake
fi
cd /usr/src
#3.download  nginx-1.8.0
wget -N http://nginx.org/download/nginx-1.8.0.tar.gz
tar -zxvf nginx-1.8.0.tar.gz
#4.download  ngx_http_substitutions_filter_module
wget -N --no-check-certificate https://raw.githubusercontent.com/arnofeng/ngx_google_deployment/master/ngx_http_substitutions_filter_module.tar.gz
tar -zxvf ngx_http_substitutions_filter_module.tar.gz
#5.configure for nginx
cd /usr/src/nginx-1.8.0
mkdir -p /var/lib/nginx/body
./configure --prefix=/etc/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-log-path=/var/log/nginx/access.log --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --lock-path=/var/lock/nginx.lock --pid-path=/var/run/nginx.pid --with-pcre-jit --with-debug --with-http_addition_module --with-http_dav_module  --with-http_gzip_static_module  --with-http_realip_module --with-http_stub_status_module --with-http_ssl_module --with-http_sub_module --with-ipv6 --with-sha1=/usr/include/openssl --with-md5=/usr/include/openssl --with-mail --with-mail_ssl_module --with-http_sub_module --add-module=/usr/src/ngx_http_substitutions_filter_module
#6.make && make install for nginx
make && make install
#7.download nginx.conf
cd /usr/src
wget -N --no-check-certificate https://raw.githubusercontent.com/arnofeng/ngx_google_deployment/master/nginx.conf
cp -r -f nginx.conf /etc/nginx/nginx.conf
sed -i "s/g.adminhost.org/$DOMAIN1/" /etc/nginx/nginx.conf
sed -i "s/x.adminhost.org/$DOMAIN2/" /etc/nginx/nginx.conf
mkdir -p /etc/nginx/vhost
#8.mkdir /var/www/
mkdir -p /var/www/google
cd /var/www/google
wget -N --no-check-certificate https://raw.githubusercontent.com/arnofeng/ngx_google_deployment/master/index.html
sed -i "s/g.adminhost.org/$DOMAIN1/" /var/www/google/index.html
sed -i "s/x.adminhost.org/$DOMAIN2/" /var/www/google/index.html
#9.set auto-start for nginx
cp -r -f /etc/rc.local /etc/rc.local_bak
sed -i 's/\"exit 0\"/\#/' /etc/rc.local
sed -i 's/\#exit 0/\#/' /etc/rc.local
sed -i 's/exit 0/\/etc\/nginx\/sbin\/nginx \nexit 0/' /etc/rc.local
#10.start nginx
/etc/nginx/sbin/nginx
if [ $? -eq 0 ]; then
	echo "
	#Everything seems OK!
	#Go ahead to see your google!"
else
	echo "
	#Installing errors!
	#Reinstall OR Contact me!"
fi