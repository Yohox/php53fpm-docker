FROM centos:centos7.1.1503
RUN curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
RUN yum clean all
RUN yum makecache
RUN yum -y swap fakesystemd systemd
RUN rpm --rebuilddb && yum -y install gcc gcc-c++ automake libtool autoconf make tar bzip2 openssl-devel libxml2-devel libcurl-devel libpng-devel
WORKDIR /opt
COPY libmcrypt-2.5.8.tar.gz .
COPY php-5.3.29.tar.bz2 .
COPY ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz .
RUN tar -xvf ./libmcrypt-2.5.8.tar.gz
RUN tar jxvf ./php-5.3.29.tar.bz2
RUN tar -xvf ./ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
RUN cd /opt/libmcrypt-2.5.8 \
    && ./configure \
    && make clean \
    && make \
    && make install 
RUN cd /opt/php-5.3.29 \
    && './configure'  '--prefix=/usr/local/php' '--enable-fpm' '--with-fpm-user=fpm' '--with-fpm-group=fpm' '--with-mysql=mysqlnd' '--with-mysqli=mysqlnd' '--with-pdo-mysql=mysqlnd' '--without-pdo-sqlite' '--without-sqlite3' '--without-sqlite' '--with-mysql-sock=/tmp/mysql.sock' '--with-curl' '--enable-mbstring' '--with-mhash' '--with-mcrypt' '--with-openssl' '--with-gd' '--enable-sockets' '--with-gettext' '--with-zlib' '--enable-zip' '--enable-soap' '--with-xmlrpc' '--enable-bcmath' \
    && make clean \
    && make \
    && make install 
RUN mkdir -vp /usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/ && cp /opt/ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so /usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/
RUN cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
RUN cp /opt/php-5.3.29/php.ini-production /usr/local/php/lib/php.ini
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/g' /usr/local/php/etc/php-fpm.conf
RUN echo $'[zend.loader] \n\
zend_loader.enable=1 \n\
zend_extension=/usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/ZendGuardLoader.so' >> /usr/local/php/lib/php.ini
RUN groupadd -r fpm && useradd -r -g fpm fpm
WORKDIR /usr/local/php/sbin/
EXPOSE 9000
CMD ["./php-fpm", "-F"]
