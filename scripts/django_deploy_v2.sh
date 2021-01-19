#!/bin/bash


# ********************************************************************

echo "====================="
echo ""
echo "Install Django"
echo ""
echo "====================="
current_user=`whoami`
domain=""
read -p "Enter domain without protocol (example.com): " domain

# path_app="$domain/app"
mkdir $domain && mkdir $domain/app && mkdir $domain/static
# mkdir $path_app -p
echo "Folder $domain - created"

cd $domain
python3 -m venv venv
echo "venv - created"
source venv/bin/activate
pip install -U pip
pip install django gunicorn psycopg2-binary

cd app
django-admin startproject config .
deactivate
echo "==========================="
echo "Django - created success!"
echo "ALLOWED_HOSTS = ['$domain', 'localhost']" >> config/settings.py
echo "ALLOWED_HOSTS - writed"


# ********************************************************************
# Create gunicorn.socket
# ********************************************************************

cd ..
mkdir gunicorn
touch gunicorn/gunicorn.socket

echo "[Unit]" >> gunicorn/gunicorn.socket
echo "Description=gunicorn socket" >> gunicorn/gunicorn.socket
echo ""
echo "[Socket]" >> gunicorn/gunicorn.socket
echo "ListenStream=/run/gunicorn.sock" >> gunicorn/gunicorn.socket
echo ""
echo "[Install]" >> gunicorn/gunicorn.socket
echo "WantedBy=sockets.target" >> gunicorn/gunicorn.socket
echo ""
echo "gunicorn/gunicorn.socket - created and updated"

sudo ln -s ~/code/$domain/gunicorn/gunicorn.socket /etc/systemd/system/
echo "symlink created: gunicorn.socket /etc/systemd/system/"


# ********************************************************************
# Create gunicorn.service
# ********************************************************************

touch gunicorn/gunicorn.service
path_template="/home/$current_user/code/$domain"

echo "[Unit]" >> gunicorn/gunicorn.service
echo "Description=gunicorn daemon" >> gunicorn/gunicorn.service
# echo "Requires=gunicorn.socket" >> gunicorn/gunicorn.service
echo "After=network.target" >> gunicorn/gunicorn.service
echo "" >> gunicorn/gunicorn.service
echo "[Service]" >> gunicorn/gunicorn.service
echo "User=$current_user" >> gunicorn/gunicorn.service
echo "Group=www-data" >> gunicorn/gunicorn.service
echo "WorkingDirectory=$path_template/app" >> gunicorn/gunicorn.service
echo "ExecStart=$path_template/venv/bin/gunicorn \\" >> gunicorn/gunicorn.service
echo "  --workers 3 \\" >> gunicorn/gunicorn.service
echo "  --bind unix:$path_template/gunicorn/gunicorn.sock \\" >> gunicorn/gunicorn.service
echo "  config.wsgi:application \\" >> gunicorn/gunicorn.service
echo "  --access-logfile $path_template/gunicorn/access.log \\" >> gunicorn/gunicorn.service
echo "  --error-logfile $path_template/gunicorn/error.log" >> gunicorn/gunicorn.service
echo "Restart=on-failure" >> gunicorn/gunicorn.service
echo "" >> gunicorn/gunicorn.service
echo "[Install]" >> gunicorn/gunicorn.service
echo "WantedBy=multi-user.target" >> gunicorn/gunicorn.service
echo "" >> gunicorn/gunicorn.service
echo "gunicorn/gunicorn.service - created and updated"

sudo ln -s ~/code/$domain/gunicorn/gunicorn.service /etc/systemd/system/
echo "symlink created: gunicorn.service /etc/systemd/system/"


# ********************************************************************
# Create Nginx config
# ********************************************************************

mkdir nginx
touch nginx/$domain.conf

echo "server {" >> nginx/$domain.conf
echo "  listen 80;" >> nginx/$domain.conf
echo "  server_name $domain;" >> nginx/$domain.conf
echo "" >> nginx/$domain.conf
echo "  location = /favicon.ico { access_log off; log_not_found off; }" >> nginx/$domain.conf
echo "  location /static {" >> nginx/$domain.conf
echo "    root /home/$current_user/code/$domain/static;" >> nginx/$domain.conf
echo "  }" >> nginx/$domain.conf
echo "  location / {" >> nginx/$domain.conf
echo "    include proxy_params;" >> nginx/$domain.conf
echo "    proxy_pass http://unix:/home/$current_user/code/$domain/gunicorn/gunicorn.sock;" >> nginx/$domain.conf
echo "  }" >> nginx/$domain.conf
echo "}" >> nginx/$domain.conf
echo "" >> nginx/$domain.conf
echo "$domain.conf - created and updated"
sudo ln -s ~/code/$domain/nginx/$domain.conf /etc/nginx/sites-enabled/
echo "$domain: sites-enabled"
# /nginx/site.conf 
# sudo ln -s ~/code/test.prck.net/nginx/test.prck.net.conf /etc/nginx/sites-enabled/

# server {
#     listen 80;
#     server_name dbms_template_domain;

#     location = /favicon.ico { access_log off; log_not_found off; }
#     location /static/ {
#         root dbms_template_path/static;
#     }
#     location / {
#         include proxy_params;
#         proxy_pass http://unix:dbms_template_path/gunicorn/gunicorn.sock;
#     }
# }


# ********************************************************************

echo "==========================="
echo ""
echo "RESTART SYSTEMS"
sudo systemctl daemon-reload
sudo systemctl start gunicorn
sudo systemctl enable gunicorn
sudo systemctl restart nginx

echo "==========================="
sudo systemctl status gunicorn
echo "==========================="
sudo systemctl status nginx
echo "==========================="
# sudo ufw delete allow 8000
# sudo ufw allow 'Nginx Full'

echo "==========================="
echo "- - - -   FINISH!   - - - -"
echo "==========================="