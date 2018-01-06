##
## create vagrant running docker inside
##  on circleic, use aws installed by circleci.yml
##
all: all-vbox

all-vbox: install-vbox add-vbox up-vbox

all-ec2: install-ec2 add-ec2 up-ec2

ifneq ("$(wildcard ../color.mk)","") # http://stackoverflow.com/questions/5553352/how-do-i-check-if-file-exists-in-makefile
include ../color.mk
endif

install-vbox: install-vagrant
	$(call colorecho, "install virtualbox")
	dpkg-query -W -f='$${Status} $${Version}\n' virtualbox; sudo apt-get -y install virtualbox virtualbox-dkms

install-ec2: install-vagrant
	$(call colorecho, "install vagrant plugins")
	vagrant plugin list | grep vagrant-aws || vagrant plugin install vagrant-aws

install-vagrant: vagrant_1.8.1_x86_64.deb
	$(call colorecho, "install vagrant")
	vagrant --version || sudo dpkg -i vagrant_1.8.1_x86_64.deb
	dpkg-query -W -f='$${Status} $${Version}\n' sshpass; sudo apt-get -y install sshpass
	vagrant plugin list | grep vagrant-global-status || vagrant plugin install vagrant-global-status

add-vbox: install-vagrant trusty-server-cloudimg-amd64-vagrant-disk1.box
	$(call colorecho, "box list")
	vagrant box list
	$(call colorecho, "box add")
	vagrant box list | grep ubuntu:14.04 || vagrant box add ubuntu:14.04 trusty-server-cloudimg-amd64-vagrant-disk1.box

up-vbox:
	$(call colorecho, "vagrant up")
	vagrant up
	$(call colorecho, "vagrant reload")
	vagrant reload
	$(call colorecho, "vagrant status")
	vagrant status

add-ec2: install-vagrant

up-ec2:
	$(call colorecho, "vagrant up")
	vagrant up ec2 --provider=aws
	$(call colorecho, "vagrant status")
	vagrant status ec2

down:
	#vagrant destroy -f
	$(call colorecho, "vagrant halt")
	vagrant halt || echo "ok"
	$(call colorecho, "vagrant stop ec2")
	vagrant destroy -f ec2 || echo "ok"
	$(call colorecho, "vagrant status")
	vagrant status || echo "ok"


vagrant_1.8.1_x86_64.deb:
	$(call colorecho, "download $@")
	wget https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.deb

trusty-server-cloudimg-amd64-vagrant-disk1.box:
	$(call colorecho, "download $@")
	wget https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box

clean: down
	$(call colorecho, "clean")
	vagrant destroy -f vbox || echo "ok"
	vagrant destroy -f ec2 || echo "ok"

	$(call colorecho, "vagrant status")
	vagrant status || echo "ok"
