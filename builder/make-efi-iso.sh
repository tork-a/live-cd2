#!/bin/bash

#https://lists.ubuntu.com/archives/ubuntu-devel/2014-November/038540.html
ROS_DISTRO=${1:-indigo}

set -x
set -e

sudo cp -ar /tmp/iso/EFI/ /tmp/iso/README.diskdefines /tmp/iso/boot/ /tmp/iso/dists/ /tmp/iso/pool/ /tmp/iso/preseed/ ./binary
sudo ls -al binary/
sudo cp -a /tmp/iso/.disk/base_installable /tmp/iso/.disk/cd_type ./binary/.disk/
echo 'https://wiki.ubuntu.com/TrustyTahr/ReleaseNotes' | sudo tee ./binary/.disk/release_notes_url

echo "Ubuntu 14.04 \"Trusty Tahr\" - Release amd64(`date '+%Y%m%d.1'`)" | sudo tee ./binary/.disk/info
cd ./binary
sudo chmod -R +r .
sudo rm -f SHA256SUMS
sudo find . -type f -exec md5sum {} \; | grep -v isolinux | grep -v md5sum.txt | sudo tee md5sum.txt

# skip install/boot http://askubuntu.com/questions/644798/custom-livecd-skip-install-boot-to-desktop-and-run-custom-app
#sed -i 's@default vesamenu.c32@default live@' isolinux/isolinux.cfg
sudo sed -i 's@^ui @#ui @' isolinux/isolinux.cfg
# remove prompt to eject cd : http://www.pendrivelinux.com/ubuntu-remove-the-prompt-to-eject-cd/
sudo sed -i 's@quiet\s\+splash\s\+--@noprompt username=tork --@' isolinux/txt.cfg
sudo sed -i 's@Ubuntu@ROS Ubuntu $(git describe --abbrev=0 --tags)@' isolinux/txt.cfg
#sudo sed -i 's@/casper/vmlinuz.efi\s\+file=/cdrom/preseed/ubuntu.seed\s\+boot=casper\s\+quiet\s\+splash\s\+--@/casper/vmlinuz.efi persistent file=/cdrom/preseed/ubuntu.seed boot=casper noprompt username=tork --@' boot/grub/grub.cfg
sudo sed -i 's@/casper/vmlinuz.efi\s\+file=/cdrom/preseed/ubuntu.seed\s\+boot=casper\s\+quiet\s\+splash\s\+--@/casper/vmlinuz.efi persistent file=/cdrom/preseed/ubuntu.seed boot=casper noprompt --@' boot/grub/grub.cfg
sudo sed -i 's@Ubuntu@ROS Ubuntu $(git describe --abbrev=0 --tags)@' boot/grub/grub.cfg
# check for human
cat isolinux/txt.cfg
cat boot/grub/grub.cfg
# check for computers
grep tork isolinux/txt.cfg
grep persistent boot/grub/grub.cfg

cd ..
cat <<EOF | sudo tee sort.txt
100 boot/
90 EFI/
80 isolinux/
70 preseed/
EOF

sudo xorriso -as mkisofs -volid "Ubuntu/ROS ja amd64" -o $ROS_DISTRO-tork-`date +%Y%m%d_%H%M%S`.iso -rock -omit-version-number -disable-deep-relocation -joliet -isohybrid-mbr /usr/lib/syslinux/isohdpfx.bin -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat -isohybrid-apm-hfsplus --sort-weight-patterns sort.txt binary/
