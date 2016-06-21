FROM osrf/ros:indigo-desktop-full
MAINTAINER Kei Okada kei.okada@gmail.com
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update

## for docker in docker : https://gist.github.com/henrik-muehe/6155333
#CIRCLECI## Fake a fuse install
RUN apt-get install libfuse2; \
              mkdir -p /tmp/fuse; \
              cd /tmp/fuse ; apt-get download fuse; \
              cd /tmp/fuse ; dpkg-deb -x fuse_* .; \
              cd /tmp/fuse ; dpkg-deb -e fuse_*; \
              cd /tmp/fuse ; rm fuse_*.deb; \
              cd /tmp/fuse ; /bin/echo -en '#!/bin/bash\nexit 0\n' > DEBIAN/postinst; \
              cd /tmp/fuse ; dpkg-deb -b . /fuse.deb; \
              cd /tmp/fuse ; dpkg -i /fuse.deb; \
              rm -fr /tmp/fuse #CIRCLECI#

# user settings (https://github.com/docker/docker/issues/16058)

## screen
RUN echo "# screenrc\n\
escape ^Tt\n\
hardstatus alwayslastline '%02c:%s %{= .g}%H%{-} %L=%-w%45L>%{=u g.}%n %t%{-}%+w %-17<%=%{= .y}(%l)'\n\
" > /etc/skel/.screenrc

## tmux
RUN echo "# Prefix\n\
set-option -g prefix C-t\n\
" > /etc/skel/.tmux.conf

## gnomerc
RUN echo "# Japnese settings\n\
gsettings set org.gnome.desktop.input-sources sources \"[('xkb', 'jp'), ('ibus', 'mozc-jp')]\"\n\
gsettings set org.gnome.desktop.input-sources xkb-options \"['ctrl:swapcaps']\"\n\
" >  /etc/skel/.gnomerc

## .emacs
RUN echo ";; emacs settings\n\
\n\
(global-set-key \"\C-h\" 'backward-delete-char)\n\
(global-set-key \"\M-g\" 'goto-line)\n\
(global-unset-key \"\C-o\" )\n\

(setq rosdistro (getenv \"ROS_DISTRO\"))\n\
(add-to-list 'load-path (format \"/opt/ros/%s/share/emacs/site-lisp\" (or rosdistro \"indigo\")))\n\
(require 'rosemacs)\n\
(invoke-rosemacs)\n\
(global-set-key \"\C-x\C-r\" ros-keymap)\n\
" >  /etc/skel/.emacs

## .ros.bashrc
RUN echo "\n\
source /opt/ros/indigo/setup.bash\n\
source \`catkin locate --shell-verbs\`\n\
" > /etc/skel/.ros.bashrc

# make home directory (user name other than ubuntu is not woking because it is hard corded /usr/share/livecd-rootfs/live-build/auto/config)
# we should not run this on live-build
RUN getent group 999 || groupadd -g 999 tork
#RUN useradd -p `perl -e "print(crypt('password', 'U6'));"` tork
RUN useradd -m -u 999 -g 999 -p U6CjLveNVb5n. tork || /bin/echo -e "password\npassword\n" | sudo passwd tork
RUN echo "tork ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/tork

##
## setup packages
##
RUN apt-get update && echo "@DATE@"

# install dev. tools
RUN apt-get -y install aptitude git ntp emacs vim wget curl

# for japanese environment
RUN apt-get -y install language-pack-gnome-ja latex-cjk-japanese xfonts-intl-japanese ibus-mozc

# ros dev. tools
RUN apt-get -y install python-catkin-tools

RUN apt-get -y install ros-$ROS_DISTRO-jsk-tools
RUN apt-get -y install ros-$ROS_DISTRO-jsk-rviz-plugins

# ros robot packages
RUN apt-get -y install ros-$ROS_DISTRO-navigation-stage
RUN apt-get -y install ros-$ROS_DISTRO-denso
RUN apt-get -y install ros-$ROS_DISTRO-rtmros-nextage
RUN apt-get -y install ros-$ROS_DISTRO-hakuto
RUN apt-get -y install ros-$ROS_DISTRO-baxter-sdk ros-$ROS_DISTRO-baxter-simulator
RUN apt-get -y install ros-$ROS_DISTRO-fetch-gazebo-demo ros-$ROS_DISTRO-fetch-teleop
RUN apt-get -y install ros-$ROS_DISTRO-pr2-simulator ros-$ROS_DISTRO-pr2-navigation
RUN apt-get -y install ros-$ROS_DISTRO-teleop-twist-joy ros-$ROS_DISTRO-teleop-twist-keyboard
RUN apt-get -y install ros-$ROS_DISTRO-uvc-camera ros-$ROS_DISTRO-opencv-apps

RUN apt-get -y install ros-$ROS_DISTRO-rosemacs

## useful tools

# install chromium
RUN apt-get -y install chromium-browser

# install gnome-open
RUN apt-get -y install libgnome2.0

# install freecad
RUN apt-get -y install freecad

# terminals
RUN apt-get -y install screen tmux

# glxinfo
RUN apt-get -y install mesa-utils

# hub
RUN wget https://github.com/github/hub/releases/download/v2.2.3/hub-linux-amd64-2.2.3.tgz -O /tmp/hub.tgz && cd /tmp && tar -xvzf hub.tgz && cd hub* && ./install

# ssh
RUN apt-get -y install openssh-client openssh-server

RUN apt-get -y install software-properties-common
# boot repair
RUN add-apt-repository -y ppa:yannubuntu/boot-repair && apt-get update && apt-get -y install boot-repair

# doocker (this create new groups, so it should be later than creating ubuntu user process)
RUN wget -qO- https://get.docker.com/ | sh
RUN usermod -aG docker tork

# inxi
RUN apt-get -y install inxi

## clean up
RUN apt-get clean

##
## setup home directory
##

# su user
USER tork
WORKDIR /home/tork/

#
RUN mkdir -p ~/Downloads
RUN wget https://github.com/tork-a/ros_seminar/archive/1.0.1.tar.gz -O ~/Downloads/ros_seminar-1.0.1.tar.gz

# settings
RUN /bin/echo -e "\n\n# ROS setup\nsource /opt/ros/$ROS_DISTRO/setup.bash\n# This file is created on $(date) from live-cd @GIT_TAG@\n#" >> ~/.bashrc
ADD CHANGELOG.rst .
RUN rosdep update || rosdep update

# make catkin workspace
RUN mkdir -p ~/catkin_ws/src
RUN wstool init ~/catkin_ws/src

# setup ros_tutorials
RUN wstool set -t ~/catkin_ws/src roscpp_tutorials https://github.com/ros/ros_tutorials.git -v $ROS_DISTRO-devel --git -y

# update and install
RUN wstool update -t ~/catkin_ws/src
RUN rosdep install -y --rosdistro $ROS_DISTRO --from-paths ~/catkin_ws/src --ignore-src

# show status
RUN wstool info -t ~/catkin_ws/src

# compile with catkin
RUN cd ~/catkin_ws; . /opt/ros/$ROS_DISTRO/setup.sh; catkin build -p 1 --no-status
