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
