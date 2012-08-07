#!/bin/bash

sudo apt-get -y update 
sudo apt-get -y upgrade 

sudo apt-get -y install mysql-client mysql-server libmysqlclient-dev
sudo apt-get -y install postgresql libpq-dev
sudo apt-get -y install apache2-mpm-worker apache2-utils libapache2-mod-fcgid apache2-suexec-custom apache2-threaded-dev curl postfix
sudo apt-get -y install php5 php-apc php-pear php5-cgi php5-cli php5-fpm php5-dev php5-curl php5-gd php5-imagick php5-imap php5-intl php5-mcrypt php5-mysql php5-sqlite php5-xdebug php5-xmlrpc php5-xsl php5-pgsql imagemagick libmagickcore-dev libmagickwand-dev

# Configure Apache and FCGID
sudo cp -R assets/etc/apache2/* /etc/apache2/
sudo cp -R assets/var/www/* /var/www/
sudo cp -R assets/home/www-data /home
sudo chown -R www-data:www-data /home/www-data

sudo sed -i '/ServerRoot \"\/etc\/apache2\"/ aServerName workstation.local' /etc/apache2/apache2.conf 
sudo a2enmod actions alias fcgid headers vhost_alias suexec  rewrite 
sudo service apache2 restart

# DB Admins
sudo apt-get -y install phpmyadmin phppgadmin pgadmin3

# configure PHP
for app in cli cgi fpm
do
    sudo sed -i 's|;\(date.timezone =\)|\1 Europe\/Paris|' /etc/php5/$app/php.ini
    sudo sed -i 's/^\(error_reporting =\).*$/\1 E_ALL | E_STRICT/' /etc/php5/$app/php.ini 
    sudo sed -i 's/^\(display_errors =\).*$/\1 On/' /etc/php5/$app/php.ini 
done

for app in cgi fpm
do
    sudo sed -i 's/^\(memory_limit =\).*$/\1 128M/' /etc/php5/$app/php.ini 
    sudo sed -i 's/^\(html_errors =\).*$/\1 On/' /etc/php5/$app/php.ini 
done

# Xdebug config
sudo sed -i '/zend_extension=.*/ a \
xdebug.remote_enable=On \
xdebug.remote_host="localhost" \
xdebug.remote_port=9001 \
xdebug.remote_handler="dbgp" \
xdebug.max_nesting_level=1000 \
xdebug.collect_params=2 \
xdebug.collect_return=On \
' /etc/php5/conf.d/xdebug.ini

# PHP Tools
sudo mkdir /opt/composer
curl -s https://getcomposer.org/installer | sudo php -- --install-dir=/opt/composer
sudo chmod 755 /opt/composer/composer.phar
sudo ln -s /opt/composer/composer.phar /usr/local/bin/composer

sudo mkdir /opt/php-cs-fixer
sudo curl http://cs.sensiolabs.org/get/php-cs-fixer.phar -o /opt/php-cs-fixer/php-cs-fixer.phar
sudo chmod 755 /opt/php-cs-fixer/php-cs-fixer.phar
sudo ln -s /opt/php-cs-fixer/php-cs-fixer.phar /usr/local/bin/php-cs-fixer

sudo pear config-set auto_discover 1
sudo pear update-channels
sudo pear upgrade
sudo pear install Console_Getopt
sudo pear install PHP_CodeSniffer

sudo pear install pear.phpunit.de/PHPUnit
sudo pear install phpunit/PHPUnit_SkeletonGenerator
sudo pear install phpunit/PHPUnit_Story
sudo pear install phpunit/DbUnit
sudo pear install phpunit/PHPUnit_Selenium
sudo pear install phpunit/PHP_Invoker

sudo pear channel-discover pear.phpmd.org 
sudo pear channel-discover pear.pdepend.org 
sudo pear install --alldeps phpmd/PHP_PMD

sudo pear channel-discover pear.phpdoc.org
sudo pear install phpdoc/phpDocumentor-alpha