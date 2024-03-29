#!/bin/bash
#change the directory and update the server
sudo su
sudo yum update -y

#install httpd and enable and start the service
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
sudo dnf install -y httpd 

#install the php and php extensions
wget php-fpm php-mysqli php-json php php-devel
sudo yum install php -y
sudo systemctl start php-fpm
sudo systemctl enable php-fpm
sudo yum install -y php php-cli php-fpm php-mysqlnd php-bcmath php-ctype php-fileinfo php-json php-mbstring php-openssl php-pdo php-gd php-tokenizer php-xml

#install mysql and myswl servers
sudo wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
sudo dnf install -y mysql80-community-release-el9-1.noarch.rpm
sudo repolist enabled | grep "mysql.*-community.*"
sudo dnf install -y mysql-community-server
sudo systemctl start mysqld
sudo yum install php-curl
sudo sed -i 's/;*\s*max_execution_time\s*=.*/max_execution_time = 300/' /etc/php.ini
sudo sed -i 's/;*\s*memory_limit\s*=.*/memory_limit = 128M/' /etc/php.ini
sudo sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

#copy file from s3 bucket into html directory 
sudo aws s3 sync s3://webserver-s3-webfiles /var/www/html

#going into html directory 
cd /var/www/html

#unzip amd copy the folder  into html directory 
sudo unzip nest-app.zip

#copy the hidden file into the html directory 
sudo cp -r nest-app/* /var/www/html
sudo cp nest-app/.editorconfig /var/www/html
sudo cp nest-app/.env /var/www/html
sudo cp nest-app/.env.example /var/www/html
sudo cp nest-app/.gitattributes /var/www/html
sudo cp nest-app/.gitignore /var/www/html
sudo cp nest-app/.htaccess /var/www/html
sudo rm -rf nest-app nest-app.zip

#change the permission of html file 
sudo chmod -R 777 /var/www/html
sudo chmod -R 777 storage/

#enable and start the Httpd service
sudo systemctl enable httpd
sudo systemctl start httpd
sudo service httpd restart

#change the .env folder to make it fully fuctioning 
cd /var/www/html
cd app
cd provider
sudo vi AppServiceProvider.phps
# update the file with line 85 command ( the below is the updated version )
<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        if (env('APP_ENV') === 'production') {\Illuminate\Support\Facades\URL::forceScheme('https');}
        //
    }
}

#boot-function code ( for the aboove line task)
if (env('APP_ENV') === 'production') {\Illuminate\Support\Facades\URL::forceScheme('https');}


#restart the apache service 
sudo service httpd restart

#updated the .env file with the information for the RDS database e.g Database username, password, Database Name, Database URL,port and DB-host)sudo vi .env
sudo vi .env

#first update the database information
localhost =Database endpoint
username=sunday
password= sunday1234

#copy the sql file from s3 to flyway-9.20.0/sql
aws s3 cp s3://nestapp-bucket/V1__nest.sql /home/ec2-user/flyway-9.20.0/sql


#migrate the sql data from s3 into RDS using flyway(cooy the entire command)
flyway -url=jdbc:mysql://instancedb.ckm6izfm7tom.us-east-1.rds.amazonaws.com:3306/devdb -user=sunday -password=sunday1234 -locations=filesystem:sql migrate


