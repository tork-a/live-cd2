^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Changelog for package live-cd
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Forthcoming
-----------
* Fix to work on kinetic/indigo (`#33 <https://github.com/tork-a/live-cd2/issues/33>`_ )
  * generate packer-postinsatll.sh
  * install apt-transport-https in chroot to support https in  /etc/apt/sources.list
  * use PACKER_LOG=1 instead of gnomon
  * remove [arch=amd64] from sources.list
  * add set -x in /usr/lib/live/build/lb_chroot_archives for debug
  * cat -n tork-docker.sh
  * export docker.com deb url to archives/tork-defaults.list
  * work around for https://github.com/ros-infrastructure/catkin_pkg/pull/190
  * use set -x for tork user commands
  * use vivid casper only required for trusty
  * revert https://github.com/tork-a/live-cd2/commit/9baedcdb515f1e2555ee75b6e3049de42ed4aacc
  * builder/Makefile use packer 1.0.3
  * build/packer.json.in: increase ssh_wait_timeout to 1500s
  * rm packer.json before run iso-test
  * build/packer.json.in: run packaer with gnomon, to avoid silent
  * kinetic/Docker: as of 2017.08.03 https://get.docker.com/ installes docker repository to sources.list, not sources.list.d/docker

* Contributors: Kei Okada

3.0.1 (2017-08-02)
------------------
* update to run `rosdep update` for important key changes https://discourse.ros.org/t/proposed-rename-of-rosdep-keys-pocketsphinx-and-xdot/1959/2

3.0.0 (2017-04-15)
------------------
* Add kinetic(`#30 <https://github.com/tork-a/live-cd2/issues/30>`_)
  * copy url to s3.txt
  * enable hakuto and send to s3 when suceeded
  * try to upload .iso, because uploading to artifacts has 3G limit   due to AWS S3, and also stop hakut, gzserver is existing in memory-usage.txt
  * get latest api from github api
  * use 1.1.0 of ros_seminar
  * do not run error on bash files
  * fix sed to remove x.xx kB
  * cat tork-defaults-config
  * need to excape call colorecho
  * add to chroot may have trouble
  * something wrong on sed set-x?
  * update release process using zip
  * use catkin_make instaed, to avoid 'OSError: out of pty devices'
  * send zipped iso https://discuss.circleci.com/t/consistently-getting-mysterious-error-error-uploading-artifacts/9849/5
  * ls CIRCLE_ARTIFACTS
  * echo CIRCLE_ARTIFACTS
  * cp indigo/kinetic
  * run make-efi-iso.sh with ROS_DISTRO
  * builder: use ISOLINUX
  * -hwe-16.04 is not available on indigo/trusty
  * remove arch=.. from source.list.d/docker.list for builder/make-iso
  * debug lb_chroot_install-packages
  * check and clean cache
  * 16.04 requires sysinux-utils (isohybrid)
  * set -x
  * set noninteractive on dpkg-reconfigure
  * ec2: update to 16.04
  * run make clean
  * need to set release
  * remove old config files
  * add to check under builder folder
  * rm iso before run build in vagrant
  * pass ROS_DISTRO to vagrant
  * build iso for both indigo/kinetic
  * need to install sudo
  * MAINTAINER is no longer set, find CMD ["/bin/bash"] to escape init commands
  * add debug code for tork-docker.sh target
  * sed ROS_DISTRO/indigo multiple times
  * some package is not released on kinetic, [pr2_controller_manager], [libuvc_camera], [nextage_ros_bridge]
  * use Ebs.VolumeSize = 80
  * fix for /tmp/iso location
  * enable to run both indigo/kinetic
  * update circleci to run docker/kinetic
  * add kinetic/Dockerfile
* Contributors: Kei Okada

2.3.3 (2016-12-07)
------------------
* indigo/Dockerfile: add mkusb `#27 <https://github.com/tork-a/live-cd2/issues/27>`_

* README.md `#26 <https://github.com/tork-a/live-cd2/issues/26>`_

  * change to use mkusb
  * we need 3.6G to burn usb with casper-rw
  * add how to run kvm
  * clean up layout
  * fix typo

* Contributors: Kei Okada

2.3.2 (2016-11-02)
------------------
* copy all iso files
* Contributors: Kei Okada

2.3.1 (2016-11-02)
------------------
* use rsync to copy iso
* Contributors: Kei Okada

2.3.0 (2016-11-01)
------------------
* add more pcakages, see `#23 <https://github.com/tork-a/live-cd2/issues/23>`_
* Contributors: Kei Okada

2.2.1 (2016-08-31)
------------------
* hakuto/Dockerfile: joystick.html have to install /var/www/html
* README.md: add how to write ios to usb
* README.md: add status badge
* Contributors: Kei Okada

2.2.0 (2016-08-25)
------------------
* add new packages

  * download 1.0.3 ros_seminar and use rosdep install to install  dependent packages

* add tork (default user) to dialout group

* misc changes

  * rm /etc/apt/sources.list.d/ duplicates, see `#16 <https://github.com/k-okada/live-cd2/issues/16>`_
  * circle.yml : disable cache docker
  * ./github_release.sh : sleep 60 after aws s3 cp

* Contributors: Kei Okada

2.1.1 (2016-08-01)
------------------
* Merge pull request `#14 <https://github.com/k-okada/live-cd2/issues/14>`_ from k-okada/nocaps
  fix problem reported from y.s. on jul/29
* builder/Makefile: use double quote for hiredocument to escape back quote command : http://stackoverflow.com/questions/13122147/prevent-expressions-enclosed-in-backticks-from-being-evaluated-in-heredocs
* builder/Makefile : fix caspser-rw partition workaround, see http://askubuntu.com/a/725709/469233
* circle.yml : always run docker build
* indigo/Dockerfile: support catkin shell-verbs
* build/Makefile: tork-defaults/debian/20_tork-defaults.gschema.override : use nocaps instead of swapcaps, required from y.suzuki
* bulid/Makefile : tork-defaults/debian/20_tork-defaults.gschema.override : fix typo : org.gnome.desktop.input-sour -> org.gnome.desktop.input-sources
* Contributors: Kei Okada

2.1.0 (2016-07-26)
------------------
* Merge pull request `#12 <https://github.com/k-okada/live-cd2/issues/12>`_ from k-okada/ubiquity_sudo
  fix for ubiquity running non-root mode; add username= to kernel parameter results black screen...
* fix : 794e129f1122a22764465ef3c3a28fb085959bd8 (comment out .gnoemrc)
* circle.yml: run apt-get udate
* (Due to black screen problem) Revert "bdcd339 (username=tork is not required for UEFI, may be ..) was wrong, we need username=tork"
  This reverts commit db4363b11bde2375b8ecf108e788533c9e85a0fe.
* fix for ubiquity running non-root mode
* Contributors: Kei Okada

2.0.6 (2016-06-24)
------------------
* Merge pull request `#13 <https://github.com/k-okada/live-cd2/issues/13>`_ from k-okada/usernamae
  * add settings to .gnoemrc has trouble, may be running gsettings before running dconf?
  * bdcd339 (username=tork is not required for UEFI, may be ..) was wrong, we need username=tork
* Contributors: Kei Okada

2.0.5 (2016-06-21)
------------------
* Merge pull request `#11 <https://github.com/k-okada/live-cd2/issues/11>`_ from k-okada/fix_sed2 fix "do not boot" problem on 2.2.4
  * username=tork is not required for UEFI, may be ..
  * remove docker-engiine, which will be installed from https://get.docker.com/ scripts
  * fix typo on gnomerc settings
  * add " in gsettigs set org.gnome...
  * builder/make-efi-iso.sh : remove quiet/splash
  * there is two spaces between /casper/vmlinuz.efi and file=/cdroms...
  * builder/make-efi-iso.sh : run grep to see if sed actually executed
* Contributors: Yuki Furuta, Kei Okada

2.0.4 (2016-06-03)
------------------
* Show version tag in meny and add CHANGELOG.rst to home directory `#7 <https://github.com/k-okada/live-cd2/issues/7>`_

  * add CHANGELOG.rst
  * add persistent for grub.cfg
  * use make command to build docker images
  * update grub.cfg menu for UEFI boot
  * update mkae-efi-iso.sh before running within vagrant
  * fix https://github.com/k-okada/live-cd2/pull/6/commits/ab9e1f702c321d0b24d3067f85946a7520b00cfa, we can not get git version within docker

* Contributors: Kei Okada

2.0.3 (2016-05-31)
------------------
* add clive-cd version on boot menu (https://github.com/k-okada/live-cd2/issues/6 )
* add comment on live-cd version within .bashrc (https://github.com/k-okada/live-cd2/issues/6 )
* cirlce.yml : docker repo name is tork not tork-a (https://github.com/k-okada/live-cd2/issues/6 )

* Contributors: Kei Okada

2.0.2 (2016-05-30)
------------------
* download ros_seminar to ~/Downloads (`#5 <https://github.com/k-okada/live-cd2/issues/5>`_)
* Fix master broken 05/28 (`#4 <https://github.com/k-okada/live-cd2/issues/4>`_ )

  * add https://github.com/RobotWebTools/rosbridge_suite/pull/219
  * https://github.com/tork-a/hakuto/pull/63 and https://github.com/tork-a/hakuto/commit/f0338a7bb2852c599bd19be261997bdd9a871375 has already been released
  * add time stamp to Dockerfile to run apt-get update everytime

* add hakuto apps, release on docker/hub (`#3 <https://github.com/k-okada/live-cd2/issues/3>`_)
* rename docker image name to tork/indigo for docker hub (`#2 <https://github.com/k-okada/live-cd2/issues/2>`_)

  * cut first n line until first MAINTAINER appears
  * add push target
  * indigo/Dockerfile: fix for catkin_tools > 0.4.x
  * rename docker image name to tork/indigo for docker hub

* Contributors: Kei Okada

2.0.1 (2016-04-13)
------------------
* add 2nd gen of live-cd
* first commit
* Contributors: Kei Okada
