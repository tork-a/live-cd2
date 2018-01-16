##
## assuming we already have vagrant running docker
##
SHELL=bash

ifneq ("$(wildcard ../color.mk)","") # http://stackoverflow.com/questions/5553352/how-do-i-check-if-file-exists-in-makefile
include ../color.mk
endif

# build iso, assuing vagrant/docker is up, and docker has been built
all: all-vagrant

all-local: clean setup-local build-local

all-vagrant: clean setup-vagrant build-vagrant

all-docker: clean setup-docker build-docker # not working?

### DEBUG change iso-build to iso-build-for for DBEUG
BUILD_TARGET=iso-build
#BUILD_TARGET=iso-build-debug
iso-build-debug:
	# install
	$(call colorecho, "install ubuntu-defaults-builder build-essential")
	sudo apt-get install -y ubuntu-defaults-builder build-essential xorriso
	# setup
	$(call colorecho, "[DEBUG] template tork-defaults files")
	ubuntu-defaults-template tork-defaults
	# build
	$(call colorecho, "template tork-defaults files")
	cd tork-defaults; dpkg-buildpackage -us -uc
	## ubuntu-defaults-image
	$(call colorecho, "build tork-defaults package")
	sudo ubuntu-defaults-image --package tork-defaults_0.1_all.deb --components main,restricted,universe,multiverse || echo "ok" # --ppa xorg-edgers/ppa

	# run twice http://blog.n-z.jp/blog/2014-07-13-build-rubylive-on-vm.html
	$(call colorecho, "build tork-defaults package again")
	[ -e binary.hybrid.iso ] || DISPLAY= sudo PROJECT=ubuntu ARCH=`dpkg-architecture -qDEB_HOST_ARCH` lb build

	# https://lists.ubuntu.com/archives/ubuntu-devel/2014-November/038540.html
	$(call colorecho, "EFI hack")
	./make-efi-iso.sh

###
###
###
setup-local:
	sudo apt-get install -y git build-essential fakeroot debhelper gdebi live-build ubuntu-defaults-builder p7zip-full
	7z x -y -o/tmp/iso/indigo  ~/Downloads/ubuntu-14.04.5-desktop-amd64.iso
	7z x -y -o/tmp/iso/kinetic ~/Downloads/ubuntu-16.04.2-desktop-amd64.iso
	make clean

build-local:
	make ${BUILD_TARGET} | tee ${BUILD_TARGET}.log

###
###
###

VAGRANT_HOSTNAME=$(shell cd ../vagrant/;vagrant ssh-config $$VM_TYPE --host vagrant | grep HostName | sed 's@^.*HostName @@')
ifeq (${VM_TYPE},ec2)
    VAGRANT_USERNAME=ubuntu
else
    VAGRANT_USERNAME=vagrant
endif
ifeq (${ROS_DISTRO},"")
    ROS_DISTRO=indigo
endif
ifeq (${ROS_DISTRO},indigo)
    RELEASE=trusty
endif
ifeq (${ROS_DISTRO},kinetic)
    RELEASE=xenial
endif
setup-vagrant:
	$(call colorecho, "docker info on host machine")
	docker -H tcp://:2375 info
	$(call colorecho, "check if vagrant is available")
	sshpass -p vagrant ssh -o StrictHostkeyChecking=no -p 22 ${VAGRANT_USERNAME}@${VAGRANT_HOSTNAME} ls -al
	$(call colorecho, "docker info on vagrant machine")
	sshpass -p vagrant ssh -o StrictHostkeyChecking=no -p 22 ${VAGRANT_USERNAME}@${VAGRANT_HOSTNAME} docker info
	$(call colorecho, "docker images on vagrant machine")
	sshpass -p vagrant ssh -o StrictHostkeyChecking=no -p 22 ${VAGRANT_USERNAME}@${VAGRANT_HOSTNAME} sh -c "uname -a; docker images"
	$(call colorecho, "make lb_build verbose for circleci")
	# make lb build verbose, not to 'took more than 10 minutes since last output'
	sshpass -p vagrant ssh -o StrictHostkeyChecking=no -p 22 ${VAGRANT_USERNAME}@${VAGRANT_HOSTNAME} bash -c "set -x; export TERM=xterm; sudo apt-get -y install live-build; sudo sed -i 's@-no-progress@@' /usr/lib/live/build/lb_binary_rootfs"

build-vagrant: #depends.txt tork-docker.sh add-apt-repository
	$(call colorecho, "build iso on vagrant machine")
	# location of builder is /opt/builder, see ../vagrant/Vagrantfile config.vm.synced_folder "../builder", "/opt/builder"
	sshpass -p vagrant ssh -o StrictHostkeyChecking=no -p 22 ${VAGRANT_USERNAME}@${VAGRANT_HOSTNAME} bash -c "set -x; uname -a; set -x; hostname; export TERM=xterm; mkdir -p build; cd build; cat /opt/builder/make-efi-iso.sh; cp -r /opt/builder/* ./; ls -al; make clean ${BUILD_TARGET} VERBOSE=1 ROS_DISTRO=${ROS_DISTRO} RELEASE=${RELEASE};"
	rsync -P --rsh="sshpass -p vagrant ssh -o StrictHostkeyChecking=no -p 22" ${VAGRANT_USERNAME}@${VAGRANT_HOSTNAME}:build/*.iso .

###
###
###
setup-docker:
	$(call colorecho, "build builder")
	docker build -t builder .
	$(call colorecho, "check if builder works")
	docker run -i -t -v ${CURDIR}/..:/opt/ws builder ls -al /opt/
	docker run -i -t -v ${CURDIR}/..:/opt/ws -v /var/run/docker.sock:/var/run/docker.sock builder docker images

build-docker:
	$(call colorecho, "build iso on docker machine")
	docker run -i -t -v ${CURDIR}/..:/opt/ws -v /var/run/docker.sock:/var/run/docker.sock builder make -C /opt/ws/builder/ ${BUILD_TARGET}

###
###
###
update-make-efi-iso-sh:
	sed -i 's@$$(git describe --abbrev=0 --tags)@$(shell git describe --abbrev=0 --tags)@' make-efi-iso.sh

depends.txt:
	$(call colorecho, "get installed packages")
	#docker run --rm tork/indigo bash -c 'echo "sudo apt-get update -qq; dpkg --get-selections | cut -d$$'"'"'\t'"'"' -f1 | xargs -r -n1 bash -c '"'"'apt-cache showpkg \$$0 | grep ubuntu.com > /dev/null && echo \$$0'"'"'" > gen_deps; bash ./gen_deps' | sed s/:amd64// | tee depends.txt
	docker run --rm tork/${ROS_DISTRO} dpkg --get-selections | sed -e 's@\s*install$$@@g' | sed 's/:amd64//' | grep -v docker-engine | tee depends.txt

tork-docker.sh:
	$(call colorecho, "get command history")
	docker history --no-trunc=true tork/${ROS_DISTRO} | tr -s " "
	# http://stackoverflow.com/questions/19104847/how-to-generate-a-dockerfile-from-an-image
	docker history --no-trunc=true tork/${ROS_DISTRO} | tr -s " " | sed -e 's/$$ROS_DISTRO/${ROS_DISTRO}/g' | /bin/sed -e 's,#(nop) USER \[\(.*\)\],sudo -u \1 -H -i <<"EOF",' | /bin/sed -e 's,#(nop) WORKDIR \(.*\),set -x; cd \1,' | /bin/sed -e 's,#(nop) ENV \(.*\),export \1,' | /bin/sed -n -e 's,[0-9.*]*\s*[kMG]\?B\s*$$,,p' | sed -n -e 's,.*/bin/sh -c \(.*\),\1,p' | /bin/sed -e 's,^\(.*\)#CIRCLECI#,#CIRCLECI# \1,' | tac | sed '0,/CMD\ \[\"\/bin\/bash\"\]/d' | tee tork-docker.sh
	echo "EOF" >> tork-docker.sh
	# workaround for https://github.com/ros-infrastructure/catkin_pkg/pull/190
	sed -i 's@apt-get clean@apt-get clean; sed -i "s/< 100:/< 1000:/" /usr/lib/python2.7/dist-packages/catkin_pkg/packages.py; cat /usr/lib/python2.7/dist-packages/catkin_pkg/packages.py@' tork-docker.sh
	cat -n tork-docker.sh

tork-defaults:
	$(call colorecho, "template tork-defaults files")
	ubuntu-defaults-template tork-defaults

	$(call colorecho, "add set -x to chroot")
	echo "set -x" >> tork-defaults/hooks/chroot
	$(call colorecho, "add set -e to chroot")
	echo "set -e" >> tork-defaults/hooks/chroot
	$(call colorecho, "setup i18n/language.txt")
	echo "en" >> tork-defaults/i18n/language.txt
	echo "ja" >> tork-defaults/i18n/language.txt
	$(call colorecho, "setup i18n/langpacks.txt")
	echo "en" >> tork-defaults/i18n/langpacks.txt
	echo "ja complete" >> tork-defaults/i18n/langpacks.txt
	$(call colorecho, "setup i18n/keyboard.txt")
	echo "jp" >> tork-defaults/i18n/keyboard.txt

	$(call colorecho, "add gnome-terminal to unity/launchers.txt")
	echo "gnome-terminal" >> tork-defaults/unity/launchers.txt
	$(call colorecho, "add chromium-browser to unity/launchers.txt")
	echo "chromium-browser" >> tork-defaults/unity/launchers.txt
	$(call colorecho, "copy tork-ros.jpg to desktop/background.jpg")
	cp tork-ros.jpg tork-defaults/desktop/background.jpg

tork-defaults/debian/20_tork-defaults.gschema.override:
	$(call colorecho, "setup 20_tork-defaults.gschema.override")
	echo "[org.gnome.desktop.input-sources]" >> tork-defaults/debian/20_tork-defaults.gschema.override
	$(call colorecho, "gsettings set org.gnome.desktop.input-sources xkb-options ['ctrl:nocaps']")
	echo "xkb-options=['ctrl:nocaps']"  >> tork-defaults/debian/20_tork-defaults.gschema.override

	$(call colorecho, 'gsettings set org.gnome.desktop.input-sources sources [("xkb", "jp") ("ibus", "mozc-jp")]')
	#echo "sources=[('xkb', 'jp'), ('ibus', 'mozc-jp')]" >> tork-defaults/debian/20_tork-defaults.gschema.override
	# custom settings https://bugs.launchpad.net/unity/+bug/1418939
	## I tried to use `gsettings set org.gnome.desktop.input-sources sources [('xkb', 'jp'), ('ibus', 'mozc-jp')]` but it dit not work until you run `gsettings reset org.gnome.desktop.input-sources sources`
	## only `org.gnome.libgnomekbd.keyboard` is working
	echo "[org.gnome.libgnomekbd.keyboard]" >> tork-defaults/debian/20_tork-defaults.gschema.override
	echo "layouts=['jp']" >> tork-defaults/debian/20_tork-defaults.gschema.override

tork-defaults/debian/rc.local:
	$(call colorecho, "setup rc.local")
	cp /etc/rc.local tork-defaults/debian/rc.local
	$(call colorecho, "Generate the SSH keys if non-existent")
	sed -i 's%exit 0%### Generate the SSH keys if non-existent\n[ ! -f /etc/ssh/ssh_host_dsa_key ] \&\& dpkg-reconfigure openssh-server\n\nexit 0%' tork-defaults/debian/rc.local
	$(call colorecho, "Remove tork-defaults.list if exists")
	sed -i 's%exit 0%### Remove tork-defaults.list if exists\n[ -f /etc/apt/sources.list.d/tork-defaults.list ] \&\& rm -f /etc/apt/sources.list.d/tork-defaults.list\n\nexit 0%' tork-defaults/debian/rc.local

tork-defaults/debian/tork-defaults.install: tork-defaults/debian/20_tork-defaults.gschema.override # tork-defaults/debian/rc.local
	$(call colorecho, "setup tork-defaults.install")
	echo "debian/20_tork-defaults.gschema.override usr/share/glib-2.0/schemas"  >> tork-defaults/debian/tork-defaults.install
	#echo "debian/rc.local etc/"  >> tork-defaults/debian/tork-defaults.install

add-apt-repository: archives/tork-defaults.list archives/tork-defaults.key
	# https://lists.debian.org/debian-live/2012/01/msg00008.html says lb2 uses config/chroot_sources but lb3 uses config/archives, but if we only have config files in archives, we have "Some packages could not be installed" error on "P: Begin installing packages (install pass)..."
	# custom repos...

archives/tork-defaults.list:
	$(call colorecho, "get sources.list.d/*.list")
	## get from docker
	mkdir -p archives/
	docker run --rm tork/${ROS_DISTRO} sh -c 'cat /etc/apt/sources.list.d/*.list' > archives/tork-defaults.list;
	docker run --rm tork/${ROS_DISTRO} sh -c 'cat /etc/apt/sources.list | grep docker.com || echo ""' >> archives/tork-defaults.list;
	sed -i 's@https://@http://@' archives/tork-defaults.list
	cat -n archives/tork-defaults.list

archives/tork-defaults.key:
	$(call colorecho, "get apt-keys")
	mkdir -p archives/
	docker run --rm tork/${ROS_DISTRO} apt-key exportall | gpg --dearmor > archives/tork-defaults.key


iso-build:
	# check
	ls -al
	sudo rm -fr cache

	# install
	$(call colorecho, "install ubuntu-defaults-builder build-essential")
	sudo apt-get install -y ubuntu-defaults-builder build-essential xorriso

	$(call colorecho, "make tork-docker.sh")
	make tork-docker.sh

	$(call colorecho, "make depends.txt")
	make depends.txt

	### ubuntu-defaults-image
	$(call colorecho, "make tork-defaults")
	make tork-defaults

	# keyboard custom settings
	$(call colorecho, "make tork-defaults.install")
	make tork-defaults/debian/tork-defaults.install

	# custom from Dockerfile
	$(call colorecho, "cat tork-docker.sh \>\> tork-defaults/hooks/chroot")
	echo -e "\n## BEGIN tork-docker.sh\n" >> tork-defaults/hooks/chroot
	cat tork-docker.sh >> tork-defaults/hooks/chroot
	echo -e "\n## END tork-docker.sh\n" >> tork-defaults/hooks/chroot

ifeq (${RELEASE},trusty)
	$(call colorecho, "use casper for vivid")
	## work around for casper-rw partition http://askubuntu.com/a/725709/469233
	## As of Jan 2018, we nolonger have casper 360 on archive.ubuntu.com
	## echo "wget http://archive.ubuntu.com/ubuntu/pool/main/c/casper/casper_1.360_amd64.deb -O /tmp/casper_1.360_amd64.deb" >> tork-defaults/hooks/chroot
	echo "wget http://launchpad.net/ubuntu/+source/casper/1.360/+build/7346252/+files/casper_1.360_arm64.deb -O /tmp/casper_1.360_amd64.deb" >> tork-defaults/hooks/chroot
	echo "sudo dpkg -x /tmp/casper_1.360_amd64.deb /tmp/casper-src" >> tork-defaults/hooks/chroot
	echo "sudo cp /tmp/casper-src/usr/share/initramfs-tools/scripts/casper /usr/share/initramfs-tools/scripts/casper" >> tork-defaults/hooks/chroot

	$(call colorecho, "fix WARNING: apt does not have a stable CLI interface yet. Use with caution in scripts")
	sudo sed -i 's@apt clean@apt-get clean@' /usr/share/livecd-rootfs/live-build/auto/build
	sudo sed -i 's@apt clean@apt-get clean@' /usr/share/livecd-rootfs/live-build/ubuntu-cpc/hooks/999-cpc-fixes.chroot
endif
	cat -n tork-defaults/hooks/chroot

	$(call colorecho, "cat depends.txt \>\> tork-defaults/depends.txt")
	cat depends.txt >> tork-defaults/depends.txt
	cat -n tork-defaults/depends.txt

	# build
	$(call colorecho, "build tork-defaults package")
	cd tork-defaults; dpkg-buildpackage -us -uc

	## ubuntu-defaults-image
	$(call colorecho, "run ubuntu-defaults-image \(config part\)")
	#cat `which ubuntu-defaults-image` | sed 's@lb config@lb config username=username hostname=ros-indigo@' | sed 's@^\(.*lb build.*\)$$@echo \1 > tork-defaults-build@'> tork-defaults-config
	cat `which ubuntu-defaults-image` | sed 's@^\(.*lb build.*\)$$@echo \1 > tork-defaults-build@'> tork-defaults-config
	# chmod u+x ./tork-defaults-config
	# sudo sed -i '0,/set -e/s//#set -e\nset -x/' tork-defaults-config
	# cat tork-defaults-config
	# sudo sed -i '0,/set -e/s//#set -e\nset -x/' /usr/lib/live/build/lb_chroot_archives
	# cat /usr/lib/live/build/lb_chroot_archives
	# sudo sed -i '0,/set -e/s//#set -e\nset -x/' /usr/lib/live/build/lb_chroot_install-packages
	# cat /usr/lib/live/build/lb_chroot_install-packages
	### sed -i 's@lb config@lb config --apt-http-proxy "http://localhost:3142"@' tork-defaults-config
	##
	##
	$(call colorecho, "enable to use https")
	sed -i 's@lb config@LB_BOOTSTRAP_INCLUDE="apt-transport-https gnupg" lb config@' tork-defaults-config

	$(call colorecho, "run tork-defaults-config")
	sh -x ./tork-defaults-config --release ${RELEASE} --package tork-defaults_0.1_all.deb --components main,restricted,universe,multiverse # --ppa xorg-edgers/ppa
	test "${RELEASE}" = "trusty" && sed -i 's@-hwe-16.04@@' config/chroot config/package-lists/* || echo "OK" # -hwe-16.04 is not available on indigo/trusty
	test "${RELEASE}" = "trusty" && sed -i 's@linux-signed-generic@linux-signed-generic-lts-xenial@' config/chroot config/package-lists/* || echo "OK" # indigo/trusty needs latest kernel
	# add-apt-repository generate fiels in archvies, since lb config cleans config/archives
	$(call colorecho, "make add-apt-repository")
	make add-apt-repository
	cp archives/* ./config/archives/

	$(call colorecho, "setup rc.local")
	mkdir -p config/includes.chroot/etc/
	cp /etc/rc.local config/includes.chroot/etc/
	$(call colorecho, "Generate the SSH keys if non-existent")
	sed -i 's%^exit 0%### Generate the SSH keys if non-existent\n[ ! -f /etc/ssh/ssh_host_dsa_key ] \&\& dpkg-reconfigure openssh-server\n\nexit 0%' config/includes.chroot/etc/rc.local
	$(call colorecho, "Remove tork-defaults.list if exists")
	sed -i 's%^exit 0%### Remove tork-defaults.list if exists\n[ -f /etc/apt/sources.list.d/tork-defaults.list ] \&\& rm -f /etc/apt/sources.list.d/tork-defaults.list\n\nexit 0%' config/includes.chroot/etc/rc.local
	cat config/includes.chroot/etc/rc.local

	$(call colorecho, "change default password")
	echo -e "#!/bin/sh\nadduser --gecos tork --disabled-login tork;echo \"tork:password\" | chpasswd" > config/hooks/01-setup_user.chroot
	# https://unix.stackexchange.com/questions/225217/what-hash-algorithms-can-i-use-in-preseeds-passwd-user-password-crypted-entry
	#echo "sed -i \"s@^\\(db_set passwd/user-password-crypted.*$$\\)@# \\\\1\\\\ndb_set passwd/user-password-crypted '\\\$$6\\\$$7QIsWAWh\\\$$eCJJATO7Xw71waswcbU5Dc/uXJb3ZwFBFq.HIhkkJcGs8mXs9IL16zmIqpRDniduDran//8gyCFc0O9r6gIcJ1'@\" /usr/share/initramfs-tools/scripts/casper-bottom/25adduser" >> config/hooks/90_ubiquity.desktop.sudo.chroot
	#echo "cat /usr/share/initramfs-tools/scripts/casper-bottom/25adduser" >> config/hooks/90_ubiquity.desktop.sudo.chroot

	$(call colorecho, "ubiquity neeed sudo") # https://github.com/k-okada/live-cd2/issues/9
	echo "sed -i 's@sh -c@sudo sh -c@' /usr/share/applications/ubiquity.desktop" >> config/hooks/90_ubiquity.desktop.sudo.chroot

	## use latest kernel
	#$(call colorecho, "use latest kernel")
	#sed -i 's@generic-lts-wily@generic-lts-xenial@' config/chroot

	$(call colorecho, "run ubuntu-defaults-image in build part")
	chmod u+x ./tork-defaults-build
	# run twice http://blog.n-z.jp/blog/2014-07-13-build-rubylive-on-vm.html
	## running twice may failed (cp: cannot stat 'chroot/boot/vmlinuz-*': No such file or directory) error
	sudo ./tork-defaults-build
	[ -e binary.hybrid.iso ] || sudo ./tork-defaults-build

	# https://lists.ubuntu.com/archives/ubuntu-devel/2014-November/038540.html
	$(call colorecho, "EFI hack")
	./make-efi-iso.sh ${ROS_DISTRO}

iso-run:
	$(call colorecho, "run ${ROS_DISTRO}.tork.iso with kvm")
	kvm --cdrom ${ROS_DISTRO}.tork.iso -m 1G


### test iso with packer
packer.json: packer.json.in
	# add iso filename and md5sum
	cat packer.json.in | sed 's#@ISO_MD5SUM@#$(shell md5sum ${ROS_DISTRO}-tork-*.iso | cut -f1 -d\ )#' | sed 's#@ISO_URL@#file://$(CURDIR)/$(shell ls ${ROS_DISTRO}-tork-*.iso)#' | tee packer.json;

packer-postinstall.sh: packer-postinstall.sh.in
	cat packer-postinstall.sh.in | sed 's#@ROS_DISTRO@#${ROS_DISTRO}#' | tee packer-postinstall.sh

packer:
	# download packer
	wget https://releases.hashicorp.com/packer/1.0.3/packer_1.0.3_linux_amd64.zip
	dpkg-query -W -f='$${Status} $${Version}\n' unzip; sudo apt-get -y install unzip
	unzip packer_1.0.3_linux_amd64.zip
	dpkg-query -W -f='$${Status} $${Version}\n' qemu-system-x86; sudo apt-get -y install qemu-system-x86
	vagrant plugin list | grep qemu || vagrant plugin install qemu


packer_virtualbox-iso_virtualbox.box: packer.json packer-postinstall.sh
	# build box
	PACKER_LOG=1 ./packer build --force -only=virtualbox-iso packer.json

packer_qemu_virtualbox.box: packer.json packer-postinstall.sh
	# build box
	PACKER_LOG=1 ./packer build --force -only=qemu packer.json

pre-iso-test:
	test -e packer.json && rm packer.json || echo "packer.json is not exist"
	test -e packer-postinstall.sh && rm packer-postinstall.sh || echo "packer-postinstall.sh is not exist"

iso-test: pre-iso-test packer packer.json packer-postinstall.sh packer_qemu_virtualbox.box
	#vagrant box remove -f iso || echo "ok"
	#vagrant destroy -f default || ecoh "ok"
	#rm -f Vagrantfile
	#vagrant box add --force iso packer_virtualbox-iso_virtualbox.box
	#vagrant box list
	#vagrant init iso
	#vagrant up



clean:
	# rm old docker image
	$(call colorecho, "reomve old docker image")
	# docker ps -a | cut -d\  -f1 | xargs docker rm
	docker images | grep none &&  sudo docker rmi $$(sudo docker images | awk '/^<none>/ { print $$3 }') || echo "oK"

	# rm ubuntu-defaults-image files
	$(call colorecho, "reomve build files")
	sudo rm -fr .build auto archives binary* chroot* config livecd.* local tork-docker.sh depends.txt docker-build

	$(call colorecho, "reomve cache")
	sudo rm -fr cache

	$(call colorecho, "reomve template files")
	# rm ubuntu-defaults-template
	sudo rm -fr tork-defaults*

help:
	@echo "iso builder for ${ROS_DISTRO}/${RELEASE}"
	@echo "docker-build: build docker image"
	@echo "docker-run:   run docker image"
	@echo "iso-build:    build iso image"
	@echo "iso-run:      run iso image in kvm"


