#!/bin/bash

GameMode=false
CustomProton=true # halts the process and waits for input
Mainline=false

function MATSH {
    case $ARG in
        "hack") hack=true ;;
        "game") game=true ;;
        "web") web=true ;;
        "app") app=true ;;
        "dev") dev=true ;;
        "ops") ops=true ;;
    esac
}

if ["$1" == "all"]; then
    hack=true
    web=true
    app=true
    dev=true
    game=true
    ops=true
elif ["$1" == "help"]; then
    echo "help"
    exit 0
else
    hack=false
    web=false   
    app=false
    dev=false
    game=false
    ops=false

    for ARG in $@; do
        MATSH
    done
fi 

echo "updating system"
sudo apt update
sudo apt upgrade -y

echo "installing chrome"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb

echo "installing tools"
sudo snap install --classic code
sudo apt install git curl -y
# for rust
curl https://sh.rustup.rs -sSf | sh -s -- -y
rustup component add rust-src --toolchain nightly-x86_64-unknown-linux-gnu
sudo apt install cargo -y

echo "create code dir"
mkdir code
cd code 

echo "cloning tom"
git clone https://github.com/eeli1/tom
cd tom 

echo "tom init"
cargo run init 
cd ~

if $dev; then
  echo 'dev'
  sudo apt install default-jre -y
  sudo snap install --classic eclipse

  sudo apt install python3-pip -y
  sudo snap install pycharm-community --classic

  sudo apt install jupyter-core circleci golang-go ruby -y
fi

if $hack; then
  sudo apt install nmap dirb gobuster -y

  curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
  chmod 755 msfinstall
  ./msfinstall
  msfupdate
  rm msfinstall  
fi

if $web; then
  sudo apt install nodejs npm webpack -y

  sudo apt install postgresql -y
  sudo apt install mysql-client-core-8.0 mysql-shell -y
fi

if $game; then
  # https://christitus.com/ultimate-linux-gaming-guide/
  sudo dpkg --add-architecture i386 

  echo "Nvidia Proprietary Driver Install"
  sudo add-apt-repository ppa:graphics-drivers/ppa -y
  sudo apt update
  sudo apt install nvidia-driver-450 libnvidia-gl-450 libnvidia-gl-450:i386 libvulkan1 libvulkan1:i386 -y

  echo "AMD Mesa Driver Install"
  sudo add-apt-repository ppa:kisak/kisak-mesa -y
  sudo apt update
  sudo apt install libgl1-mesa-dri:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386 -y

  echo "Mainline (Debian Bleeding Edge)"
  if $Mainline; then
    echo 'deb http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-kernel.list && wget -qO - https://dl.xanmod.org/gpg.key | sudo apt-key add -
    sudo apt update && sudo apt install linux-xanmod -y
    sudo apt install wget -y
    wget https://raw.githubusercontent.com/pimlie/ubuntu-mainline-kernel.sh/master/ubuntu-mainline-kernel.sh
    chmod +x ubuntu-mainline-kernel.sh
    sudo mv ubuntu-mainline-kernel.sh /usr/local/bin/
  fi

  echo "Wine Dependancies and Lutris"
  wget -nc https://dl.winehq.org/wine-builds/winehq.key
  sudo apt-key add winehq.key
  sudo add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main' -y
  sudo add-apt-repository ppa:lutris-team/lutris -y
  sudo apt update
  sudo apt-get install --install-recommends winehq-staging -y
  sudo apt-get install libgnutls30:i386 libldap-2.4-2:i386 libgpg-error0:i386 libxml2:i386 libasound2-plugins:i386 libsdl2-2.0-0:i386 libfreetype6:i386 libdbus-1-3:i386 libsqlite3-0:i386 -y
  sudo apt-get install lutris -y

  echo "GameMode"
  if $GameMode; then
    sudo apt install meson libsystemd-dev pkg-config ninja-build git libdbus-1-dev libinih-dev dbus-user-session -y
    git clone https://github.com/FeralInteractive/gamemode.git
    cd gamemode
    git checkout 1.5.1 # omit to build the master branch
    ./bootstrap.sh
  fi

  echo "CustomProton"
  if $CustomProton; then
    cd ~
    wget https://raw.githubusercontent.com/Termuellinator/ProtonUpdater/master/cproton.sh
    sudo chmod +x cproton.sh
    ./cproton.sh
  fi

  echo "steam"
  sudo add-apt-repository multiverse
  sudo apt update
  sudo apt install steam -y
fi


if $ops; then
  sudo snap install postman -y

  sudo apt install docker.io docker-ce docker-ce-cli containerd.io -y

  sudo apt-get install -y apt-transport-https ca-certificates curl
  sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
  echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update
  sudo apt-get install -y kubelet kubeadm kubectl -y
  sudo apt-mark hold kubelet kubeadm kubectl -y
  sudo snap install microk8s

  sudo snap install ipfs
fi

if $app; then
  sudo snap install --classic android-studio

  sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev -y
  sudo snap install flutter --classic
fi 

# https://eeli1.github.io/my/repos.txt
# install all github prijects curl https://api.github.com/users/eeli1/repos