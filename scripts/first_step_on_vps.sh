#!/bin/bash

# the root user works here!


# ********************************************************************
# Update and upgrade OS
# ********************************************************************
echo "====================="
echo ""
echo "Start update and upgrade OS:"
echo ""
echo "====================="
apt-get clean -y && apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y
echo ""


# ********************************************************************
# Install packages
# ********************************************************************
echo "====================="
echo ""
echo "Install packages:"
echo ""
echo "====================="
apt-get install -y sudo vim htop mc git curl wget nodejs sqlite3 nginx unzip zip make gcc build-essential
apt-get install -y libsqlite3-dev python3-pip python3-venv python3-lxml python3-dev python3-pil 
python3 -m pip install -U pip

# apt-get install -y postgresql postgresql-contrib libpq-dev 

apt-get install -y python-libxml2 python-libxslt1 python-dev python-pil 
apt-get install -y tree redis-server gnumeric supervisor tk-dev xz-utils
apt-get install -y libssl-dev zlib1g-dev libbz2-dev libreadline-dev llvm libncurses5-dev libncursesw5-dev libffi-dev liblzma-dev
apt-get install -y libxslt-dev libxml2-dev libxslt1-dev libjpeg-dev libfreetype6-dev libcurl4-openssl-dev libgdbm-dev libnss3-dev
echo ""


# ********************************************************************
# Create new user
# ********************************************************************
new_user_name=""
echo "====================="
echo ""
echo "Create new user"
echo ""
echo "====================="
echo ""
read -p "Enter new user name: " new_user_name
adduser $new_user_name
echo ""


# ********************************************************************
# Add new user in group sudo
# ********************************************************************
echo "====================="
echo ""
echo "Add $new_user_name in group sudo.."
echo ""
echo "====================="
echo ""
usermod -aG sudo $new_user_name
echo "====================="
echo ""


# ********************************************************************
# Close entrance for user "root" and change port ssh
# ********************************************************************
echo "====================="
echo ""
echo "Close entrance for user: root "
echo ""
echo "====================="
echo "PermitRootLogin no"
echo "" >> /etc/ssh/sshd_config 
echo "# USERS SETTINGS:" >> /etc/ssh/sshd_config 
echo "" >> /etc/ssh/sshd_config 
echo "PermitRootLogin no" >> /etc/ssh/sshd_config 
new_port_ssh=""
read -p "Enter new port for ssh (example: 1234): " new_port_ssh
echo "Port $new_port_ssh" >> /etc/ssh/sshd_config 
echo "Restart ssh..."
service ssh restart
echo ""


# ********************************************************************
# Install and setting firewall ufw
# ********************************************************************
echo "====================="
echo ""
echo "Install firewall UFW"
echo ""
echo "====================="
apt-get install -y ufw
ufw allow OpenSSH
ufw allow $new_port_ssh
ufw allow 'Nginx HTTP'
ufw logging on
echo "====================="
echo ""
ufw enable
ufw status numbered
echo ""
echo "====================="
echo ""

# ********************************************************************
# Install and setting fail2ban
# ********************************************************************
echo "====================="
echo ""
echo "Install fail2ban"
echo ""
echo "====================="
apt-get install -y fail2ban
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
service fail2ban restart
echo ""

# ********************************************************************
# Instal zsh:
# ********************************************************************
echo "====================="
echo ""
echo "Instal zsh:"
echo ""
echo "====================="
apt-get install -y zsh zsh-syntax-highlighting fonts-powerline # install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" # install oh-my-zsh
chsh -s $(which zsh) # Change your default shell
echo ""

# ********************************************************************
# - - -  FINISH!  - - -
# ********************************************************************
echo "====================="
echo "- - -  FINISH!  - - -"
echo "====================="
echo "- -   REBOOTING!  - -"
echo "====================="
reboot
exit 0