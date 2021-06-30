#!/bin/bash -e
clear
mkdir wordpress
cd wordpress
echo "============================================"
echo "WordPress Install Script"
echo "============================================"
echo "Database Name: "
read -e dbname
echo "Database User: "
read -e dbuser
echo "Database Password: "
read -s dbpass
echo "run install? (y/n)"
read -e run
if [ "$run" == n ] ; then
exit
else
echo "============================================"
echo "A robot is now installing WordPress for you."
echo "============================================"
#download wordpress
curl -O https://wordpress.org/latest.tar.gz
#unzip wordpress
tar -zxvf latest.tar.gz
#change dir to wordpress
cd wordpress
#copy file to parent dir
cp -rf . ..
#move back to parent dir
cd ..
#remove files from wordpress folder
rm -R wordpress
#create wp config
cp wp-config-sample.php wp-config.php
#set database details with perl find and replace
perl -pi -e "s/database_name_here/$dbname/g" wp-config.php
perl -pi -e "s/username_here/$dbuser/g" wp-config.php
perl -pi -e "s/password_here/$dbpass/g" wp-config.php

#set WP salts
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' wp-config.php

echo "Cleaning..."
#remove zip file
rm latest.tar.gz
#download headless theme
echo "Download starter theme..."
rm -rf wp-content
git clone https://github.com/14-pixels/headless-wordpress.git wp-content
echo "Install Plugins..."
cd wp-content
composer self-update --1 && COMPOSER=composer-public.json composer install
echo "Download frontend starter..."
cd ..
cd ..
git clone git@github.com:WebDevStudios/nextjs-wordpress-starter.git frontend
cd frontend
npm i --legacy-peer-deps
#remove bash script
cd ..
rm wp.sh
echo "========================="
echo "Installation is complete."
echo "========================="
fi
