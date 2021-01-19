#!/bin/bash

# ********************************************************************
# systemdимеет большую поддержку в этой ситуации. Я
# предполагаю, что вы запускаете веб-сервер, такой как Nginx, 
# перед приложениями в качестве обратного прокси-сервера для маршрутизации 
# трафика в нужную конечную точку для каждого экземпляра Gunicorn, 
# используя их уникальные имена сокетов. 
# Здесь я остановлюсь на systemdконфигурации.

# Желательно иметь возможность останавливать и запускать отдельные 
# gunicorn экземпляры, а также рассматривать их как экземпляры, 
# single serviceкоторые можно останавливать или запускать вместе.

# systemdРешение предполагает создание «цели» , 
# который будет использоваться для лечения как экземпляров 
# в качестве одной службы. Затем будет использоваться один «шаблонный блок», 
# чтобы вы могли добавить несколько стрелков к «цели».

# ********************************************************************

# Во-первых /etc/systemd/system/gunicorn.target:

# ********************************************************************
mkdir $path_apps/$name_app/settings
cd $path_apps/$name_app/settings

echo "[Unit]" >> gunicorn.target
echo "Description=Gunicorn" >> gunicorn.target
echo "Documentation=https://example.com/path/to/your/docs" >> gunicorn.target
echo "" >> gunicorn.target
echo "[Install]" >> gunicorn.target
echo "WantedBy=multi-user.target" >> gunicorn.target


sudo ln -s $path_apps/$name_app/settings/gunicorn.target /etc/systemd/system/

# Вот и все. Вы создали цель, которая при включении запускается при загрузке. 

# ********************************************************************
# Теперь /etc/systemd/system/gunicorn@.service 
# ********************************************************************
# файл шаблона:

echo "[Unit]" >> gunicorn@.service 
echo "Description=gunicorn daemon" >> gunicorn@.service 
echo "After=network.target" >> gunicorn@.service 
echo "PartOf=gunicorn.target" >> gunicorn@.service 
echo "ReloadPropagatedFrom=gunicorn.target" >> gunicorn@.service 
echo "" >> gunicorn@.service
echo "" >> gunicorn@.service
echo "[Service]" >> gunicorn@.service
echo "User=`whoami`" >> gunicorn@.service
echo "Group=www-data" >> gunicorn@.srvice
echo "WorkingDirectory=/home/ubuntu/webapps/%i/app" >> gunicorn@.service
echo "" >> gunicorn@.service
echo "ExecStart=/home/ubuntu/webapps/djangoenv/bin/gunicorn \\" >> gunicorn@.service
echo "  --workers 3 \\" >> gunicorn@.service
echo "  --bind unix:/home/ubuntu/webapps/%i/gunicorn.sock \\" >> gunicorn@.service
echo "  --access-logfile $path_apps/logs/access.log \\" >> gunicorn@.service
echo "  --error-logfile $path_apps/logs/error.log \\" >> gunicorn@.service
echo "$name_app.wsgi:application" >> gunicorn@.service
echo "Restart=on-failure" >> gunicorn@.service
echo "" >> gunicorn@.service
echo "" >> gunicorn@.service
echo "[Install]" >> gunicorn@.service
echo "WantedBy=gunicorn.target" >> gunicorn@.service

sudo ln -s $path_apps/$name_app/settings/gunicorn@.service /etc/systemd/system/

# ********************************************************************
# Обратите внимание на изменения:

# Каждый экземпляр теперь PartOf=является целью.
# Включение этой службы заставит ее загружаться как зависимость от цели из-за обновленного WantedBy=
# Путь к WorkingDirectory=сокету и теперь использует переменные, потому что файл теперь является шаблоном.
# ********************************************************************

# Запустить или остановить все экземпляры Gunicorn одновременно, мы можем просто:
# systemctl start gunicorn.target
# systemctl stop gunicorn.target
sudo systemctl start gunicorn.target

# Мы можем использовать enableи disable 
# для добавления и удаления новых экземпляров Gunicorn на лету:
# systemctl enable  gunicorn@name_app_one
# systemctl disable gunicorn@name_app_two


# Мы также можем stop и start отдельно от услуги:
# systemctl start gunicorn@name_app_one
# systemctl stop gunicorn@name_app_one
# systemctl restart gunicorn@name_app_one

sudo systemctl start gunicorn@$name_app


# Исходный gunicorn.service файл больше не нужен в этом шаблоне и может быть удален.


echo ""
echo "==========================="
echo "- - - -   FINISH!   - - - -"
echo "==========================="