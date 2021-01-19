#!/bin/bash

# echo "command = '/home/`whoami`/www/projectname/env/bin/gunicorn'" >> gunicorn_config.py
# echo "pythonpath = '/home/`whoami`/www/projectname/projectname'" >> gunicorn_config.py
# echo "bind = '127.0.0.1:8001'" >> gunicorn_config.py
# echo "workers = 3" >> gunicorn_config.py
# echo "user = '`whoami`' " >> gunicorn_config.py
# echo "limit_request_fields = 32000" >> gunicorn_config.py
# echo "limit_request_field_size = 0" >> gunicorn_config.py
# echo "raw_env = 'DJANGO_SETTINGS_MODULE=projectname.settings'" >> gunicorn_config.py


# ********************************************************************
# Configuration Nginx
# ********************************************************************
echo "====================="
echo ""
echo "Configuration Nginx"
echo ""
echo "====================="
chown -R www-data:www-data /var/www
usermod -aG www-data $new_user_name
chmod go-rwx /var/www
chmod go+x /var/www
chgrp -R www-data /var/www
chmod -R go-rwx /var/www
chmod -R g+rwx /var/www
echo ""


# ********************************************************************
# Django 
# ********************************************************************
echo "====================="
echo ""
echo "Install Django"
echo ""
echo "====================="
current_user = `whoami`
name_dj_proj=""
read -p "Enter name for Django project: " name_dj_proj
mkdir ~/code/$name_dj_proj -p

path_sgun="~/code/$name_dj_proj/bin/start_gunicorn.sh"
touch $path_sgun
chmod +x $path_sgun
echo "#!/bin/bash" >> $path_sgun
echo "source /home/$current_user/code/$name_dj_proj/venv/bin/activate" >> $path_sgun
echo "source /home/$current_user/code/$name_dj_proj/venv/bin/postactivate" >> $path_sgun
echo "exec gunicorn  -c '/home/$current_user/code/$name_dj_proj/gunicorn_config.py' $name_dj_proj.wsgi" >> $path_sgun

cd ~/www/$name_dj_proj
python3 -m venv venv
source venv/bin/activate
pip install -U pip
pip install django gunicorn
pip install ipython
django-admin startproject $name_dj_proj .
cd $name_dj_proj/
./manage.py startapp main
touch gunicorn_config.py
echo "command = '/home/$new_user_name/www/$name_dj_proj/env/bin/gunicorn'" >> gunicorn_config.py
echo "pythonpath = '/home/$new_user_name/www/$name_dj_proj/$name_dj_proj'" >> gunicorn_config.py
echo "bind = '127.0.0.1:8001'" >> gunicorn_config.py
echo "workers = 3" >> gunicorn_config.py
echo "user = '$new_user_name' " >> gunicorn_config.py
echo "limit_request_fields = 32000" >> gunicorn_config.py
echo "limit_request_field_size = 0" >> gunicorn_config.py
echo "raw_env = 'DJANGO_SETTINGS_MODULE=$name_dj_proj.settings'" >> gunicorn_config.py


