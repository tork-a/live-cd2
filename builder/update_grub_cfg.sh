#!/bin/bash

set -x
set -e

sudo sed -i 's@/casper/vmlinuz.efi\s\+file=/cdrom/preseed/ubuntu.seed\s\+boot=casper\s\+quiet\s\+splash\s\+--@/casper/vmlinuz.efi persistent file=/cdrom/preseed/ubuntu.seed boot=casper noprompt username=tork --@' boot/grub/grub.cfg
sudo sed -i 's@Ubuntu@ROS Ubuntu $(git describe --abbrev=0 --tags)@' boot/grub/grub.cfg
