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
