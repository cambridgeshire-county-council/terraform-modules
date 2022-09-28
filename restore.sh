#!/bin/bash

wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U ./amazon-cloudwatch-agent.rpm


/etc/profile.d/ci_setup.sh
echo Downloading server files
aws s3 cp s3://cambs-insight/data.cambridgeshireinsight.org.uk.zip . #--quiet
echo Downloading database files
aws s3 cp s3://cambs-insight/Dump20210223.sql . #--quiet
sed -i 's/SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;//' Dump20210223.sql
sed -i 's/SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;//' Dump20210223.sql
sed -i 's/SET @@SESSION.SQL_LOG_BIN= 0;//' Dump20210223.sql
sed -i 's/SET @@GLOBAL.GTID_PURGED=.*//' Dump20210223.sql
echo Populating database
mysql -h $MYSQL_ENDPOINT -P 3306 -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" --execute "CREATE DATABASE $MYSQL_DBNAME"
#mysql -h $MYSQL_ENDPOINT -P 3306 -u $MYSQL_USER -p$MYSQL_PASSWORD --execute "CREATE DATABASE $MYSQL_DBNAME"
mysql -h $MYSQL_ENDPOINT -P 3306 -u $MYSQL_USER -p"$MYSQL_PASSWORD" "$MYSQL_DBNAME" < Dump20210223.sql
echo Unzipping server files
unzip -q data.cambridgeshireinsight.org.uk.zip -d .
sed -i 's/datacamb_datadb/'"$MYSQL_DBNAME"'/g' data.cambridgeshireinsight.org.uk/sites/default/settings.php
sed -i 's/datacamb_datau/'"$MYSQL_USER"'/g' data.cambridgeshireinsight.org.uk/sites/default/settings.php
sed -i 's/qAGU@ppnCzM7/'"$MYSQL_PASSWORD"'/g' data.cambridgeshireinsight.org.uk/sites/default/settings.php
sed -i 's/localhost/'"$MYSQL_ENDPOINT"'/g' data.cambridgeshireinsight.org.uk/sites/default/settings.php
IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
sed -i \"s/data.cambridgeshireinsight.org.uk/$IP/g\" data.cambridgeshireinsight.org.uk/sites/default/settings.php
sed -i "s/'port' => ''/'port' => '3306'/g" data.cambridgeshireinsight.org.uk/sites/default/settings.php
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php.ini
sed -i '/<Directory \"\/var\/www\/html\">/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/' /etc/httpd/conf/httpd.conf
sed -i 's/RewriteCond %%{HTTPS} off//g' .htaccess
sed -i 's/RewriteCond %%{HTTP:X-Forwarded-Proto} !https//g' data.cambridgeshireinsight.org.uk/.htaccess
sed -i 's/RewriteCond %%{REQUEST_URI} !^\/\\.well-known\/acme-challenge\/\[0-9a-zA-Z_-]+\$//g' data.cambridgeshireinsight.org.uk/.htaccess
sed -i 's/RewriteCond %%{REQUEST_URI} !^\/\\.well-known\/cpanel-dcv\/\[0-9a-zA-Z_-]+\$//g' data.cambridgeshireinsight.org.uk/.htaccess
sed -i 's/RewriteCond %%{REQUEST_URI} !^\/\\.well-known\/pki-validation\/(?:\\ Ballot169)?//g' data.cambridgeshireinsight.org.uk/.htaccess
sed -i 's/RewriteCond %%{REQUEST_URI} !^\/\\.well-known\/pki-validation\/\[A-F0-9]{32}\\.txt(?:\\ Comodo\\ DCV)?\$//g' data.cambridgeshireinsight.org.uk/.htaccess
sed -i 's/RewriteRule ^(.*)\$ https:\/\/%%{HTTP_HOST}%%{REQUEST_URI} \[L,R=301]//g' data.cambridgeshireinsight.org.uk/.htaccess
echo Moving server files
mv data.cambridgeshireinsight.org.uk/* /var/www/html/
mv data.cambridgeshireinsight.org.uk/.htaccess /var/www/html/