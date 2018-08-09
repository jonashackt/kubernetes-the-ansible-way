sudo pacman -Sy vagrant virtualbox
vagrant plugin install vagrant-dns
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-hostsupdater
vagrant dns --start
