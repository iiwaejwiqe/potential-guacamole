#!/bin/bash

# Tworzenie pliku swap o wielkości 1GB
sudo fallocate -l 10G /swapfile

# Zabezpieczenie pliku przed odczytem i zapisem przez osoby trzecie
sudo chmod 600 /swapfile

# Tworzenie partycji swap
sudo mkswap /swapfile

# Włączanie partycji swap
sudo swapon /swapfile

# Dodawanie partycji swap do automatycznego wczytywania przy każdym uruchomieniu serwera
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Instalacja i konfiguracja narzędzia dla zarządzania pamięcią
sudo apt-get install -y sysfsutils
echo 'vm.swappiness = 10' | sudo tee -a /etc/sysfs.conf

# Instalacja narzędzia do kompresji plików
sudo apt-get install -y zlib1g-dev

# Zmiana wielkości bufora dla dysku twardego
echo 'vm.dirty_background_ratio = 5' | sudo tee -a /etc/sysfs.conf
echo 'vm.dirty_ratio = 10' | sudo tee -a /etc/sysfs.conf

# Włączanie funkcji TCP timestamps
echo 'net.ipv4.tcp_timestamps = 1' | sudo tee -a /etc/sysctl.conf

# Włączanie funkcji TCP window scaling
echo 'net.ipv4.tcp_window_scaling = 1' | sudo tee -a /etc/sysctl.conf

# Zwiększenie wielkości pamięci podręcznej dla DNS
echo 'options single-request-reopen' | sudo tee -a /etc/resolvconf/resolv.conf.d/head

# Zmiana wartości opcji noatime dla systemu plików
sudo sed -i 's/errors=remount-ro 0/errors=remount-ro,noatime 0/g' /etc/fstab

# Zaktualizowanie konfiguracji systemu
sudo sysctl -p

# Zmiana portu SSH
sudo sed -i 's/#Port 22/Port 1337/g' /etc/ssh/sshd_config

# Ograniczenie dozwolonych protokołów i metod uwierzytelniania
sudo echo "Protocol 2
Ciphers aes128-ctr,aes192-ctr,aes256-ctr
MACs hmac-sha2-256,hmac-sha2-512
PermitRootLogin no
MaxAuthTries 5
LoginGraceTime 30
Banner /etc/issue.net
AllowUsers yourusername
PasswordAuthentication no
UsePAM no
PubkeyAuthentication yes
AuthorizedKeysFile	.ssh/authorized_keys" >> /etc/ssh/sshd_config

# Włączenie i uruchomienie fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Ustawienie reguł dla firewalla i włączenie firewalla
sudo apt-get install -y ufw
sudo ufw allow 1337/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 1337/udp
sudo ufw allow 80/udp
sudo ufw allow 443/udp
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

# Zmiana DNS-ów serwera
echo "nameserver 1.1.1.1
nameserver 8.8.8.8" > /etc/resolv.conf

# Instalacja htop
sudo apt-get update
sudo apt-get install -y htop

# Wyczyszczenie cache plików i DNS
sudo echo 3 > /proc/sys/vm/drop_caches
sudo service nscd restart

# Optymalizacja serwera
sudo echo "fs.file-max = 1000000
fs.nr_open = 1000000
kernel.pid_max = 4194304
kernel.threads-max = 4194304
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 262144
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 5
net.ipv4.tcp_syn_retries = 5
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_keepalive_time = 30
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 87380 16777216
net.ipv4.udp_rmem_min = 16384
net.ipv4.udp_wmem_min = 16384" >> /etc/sysctl.conf
sudo sysctl -p
