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
