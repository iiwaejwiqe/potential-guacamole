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

# Zwiększenie limitu plików otwartych jednocześnie
echo 'fs.file-max = 1000000' | sudo tee -a /etc/sysctl.conf

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
MaxAuthTries 3
LoginGraceTime 30
Banner /etc/issue.net
AllowUsers yourusername
PasswordAuthentication no
UsePAM no
PubkeyAuthentication yes
AuthorizedKeysFile	.ssh/authorized_keys" >> /etc/ssh/sshd_config

# Zabezpieczenie przed atakami typu brute-force
sudo apt-get install -y fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo sed -i 's/port = ssh/port = 1337/g' /etc/fail2ban/jail.local
sudo echo "[sshd]
enabled  = true
maxretry = 5
bantime  = 600
findtime = 600
action = iptables-multiport[name=sshd, port="1337", protocol=tcp]
sendmail-whois[name=sshd, dest=hello@local.localhost, sender=fail2ban@yourserver.com]
" >> /etc/fail2ban/jail.local

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
