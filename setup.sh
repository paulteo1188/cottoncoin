#/bin/bash

cd ~
echo "****************************************************************************"
echo "* Ubuntu 16.04 is the recommended opearting system for this install.       *"
echo "*                                                                          *"
echo "* This script will install and configure your Bitcoin Green  masternodes.  *"
echo "****************************************************************************"
echo && echo && echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!                                                 !"
echo "! Make sure you double check before hitting enter !"
echo "!                                                 !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo && echo && echo

echo "Do you want to install all needed dependencies (no if you did it before)? [y/n]"
read DOSETUP

if [ $DOSETUP = "y" ]  
then
  sudo apt-get update
  sudo apt-get -y upgrade
  sudo apt-get -y dist-upgrade
  sudo apt-get update
  sudo apt-get install -y zip unzip

  cd /var
  sudo touch swap.img
  sudo chmod 600 swap.img
  sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
  sudo mkswap /var/swap.img
  sudo swapon /var/swap.img
  sudo free
  sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
  cd

  wget http://174.138.44.238/Cotton.zip
  unzip Cotton.zip
  chmod +x Linux/bin/*
  sudo mv  Linux/bin/* /usr/local/bin
  rm -rf Cotton.zip Windows Linux Mac

  sudo apt-get install -y ufw
  sudo ufw allow ssh/tcp
  sudo ufw limit ssh/tcp
  sudo ufw logging on
  echo "y" | sudo ufw enable
  sudo ufw status

  mkdir -p ~/bin
  echo 'export PATH=~/bin:$PATH' > ~/.bash_aliases
  source ~/.bashrc
fi

## Setup conf
mkdir -p ~/bin
echo ""
echo "Configure your masternodes now!"
echo "Type the IP of this server, followed by [ENTER]:"
read IP

echo ""
echo "How many nodes do you want to create on this server? [min:0 Max:20]  followed by [ENTER]:"
read MNCOUNT


for i in `seq 1 1 $MNCOUNT`; do
  echo ""
  echo "Enter alias for new node"
  read ALIAS  

  echo ""
  echo "Enter port for node $ALIAS"
  read PORT

  echo ""
  echo "Enter masternode private key for node $ALIAS"
  read PRIVKEY

  echo ""
  echo "Enter RPC Port (Any valid free port: i.E. 17100)"
  read RPCPORT

  ALIAS=${ALIAS}
  CONF_DIR=~/.cotton_$ALIAS

  # Create scripts
  echo '#!/bin/bash' > ~/bin/cottond_$ALIAS.sh
  echo "cottoncoind -daemon -conf=$CONF_DIR/cotton.conf -datadir=$CONF_DIR "'$*' >> ~/bin/cottond_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/cotton-cli_$ALIAS.sh
  echo "cottoncoin-cli -conf=$CONF_DIR/cotton.conf -datadir=$CONF_DIR "'$*' >> ~/bin/cotton-cli_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/cotton-tx_$ALIAS.sh
  echo "cottoncoin-tx -conf=$CONF_DIR/cotton.conf -datadir=$CONF_DIR "'$*' >> ~/bin/cotton-tx_$ALIAS.sh 
  chmod 755 ~/bin/cotton*.sh

  mkdir -p $CONF_DIR
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> cotton.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> cotton.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> cotton.conf_TEMP
  echo "rpcport=$RPCPORT" >> cotton.conf_TEMP
  echo "listen=1" >> cotton.conf_TEMP
  echo "server=1" >> cotton.conf_TEMP
  echo "daemon=1" >> cotton.conf_TEMP
  echo "logtimestamps=1" >> cotton.conf_TEMP
  echo "maxconnections=256" >> cotton.conf_TEMP
  echo "masternode=1" >> cotton.conf_TEMP
  echo "" >> cotton.conf_TEMP

  echo "" >> cotton.conf_TEMP
  echo "port=$PORT" >> cotton.conf_TEMP
  echo "masternodeaddr=$IP:$PORT" >> cotton.conf_TEMP
  echo "masternodeprivkey=$PRIVKEY" >> cotton.conf_TEMP
  sudo ufw allow $PORT/tcp

  mv cotton.conf_TEMP $CONF_DIR/cotton.conf
  
  sh ~/bin/cottond_$ALIAS.sh
done
