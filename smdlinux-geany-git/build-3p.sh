#!/bin/bash
#https://wiki.archlinux.org/index.php/DeveloperWiki:Building_in_a_Clean_Chroot

destination1=$HOME"/Documents/smdlinux/smdlinux-repo/smdlinux_repo/x86_64/"
destination2=$HOME"/Documents/smdlinux/smdlinux-repo/smdlinux_repo_3party/x86_64/"
destination3=$HOME"/Documents/smdlinux/smdlinux-repo/smdlinux_repo_iso/x86_64/"
destination4=$HOME"/Documents/smdlinux/smdlinux-repo/smdlinux_repo_testing/x86_64/"
destination7=$HOME"/Documents/smdlinux/archives/packages"

destiny=$destination1

# 2. makepkg"
# 1. chroot"

CHOICE=1
pwdpath=$(echo $PWD)
pwd=$(basename "$PWD")

makepkglist="some-package"

for i in $makepkglist
do
  if [[ "$pwd" == "$i" ]] ; then
  CHOICE=2
  fi
done
search=""
search1=$(basename "$PWD")
search2=smdlinux

search=$search1
rm -rf /tmp/tempbuild
if test -f "/tmp/tempbuild"; then
  rm /tmp/tempbuild
fi
mkdir /tmp/tempbuild
cp -r $pwdpath/* /tmp/tempbuild/
#cp -r $pwdpath/.* /tmp/tempbuild

cd /tmp/tempbuild/

if [[ $CHOICE == "1" ]] ; then

  tput setaf 2
  echo "#############################################################################################"
  echo "#########        Let us build the package in CHROOT "$(basename `pwd`)
  echo "#############################################################################################"
  tput sgr0
  CHROOT=$HOME/Documents/chroot
  arch-nspawn $CHROOT/root pacman -Syu
  makechrootpkg -c -r $CHROOT

  echo "Signing the package"
  echo "#############################################################################################"
  gpg --detach-sign $search*pkg.tar.zst

else

  tput setaf 3
  echo "#############################################################################################"
  echo "#########        Let us build the package with MAKEPKG "$(basename `pwd`)
  echo "#############################################################################################"
  tput sgr0
  makepkg --sign
fi

echo "Moving created files to " $destiny
echo "#############################################################################################"
cp $search*pkg.tar.zst $destiny
cp $search*pkg.tar.zst.sig $destiny

#take special care to special packages
if [[ $search == "perl-checkupdates-aur" ]]; then
  cp checkupdates*pkg.tar.zst $destiny
  cp checkupdates*pkg.tar.zst.sig $destiny
fi


firstLetter="$(echo $search | head -c 1)"

echo "Moving created files to " $destination7/$firstLetter/$search1
echo "#############################################################################################"

[ -d $destination7/$firstLetter ] && echo "Directory " $firstLetter " exists" || mkdir $destination7/$firstLetter
[ -d "$destination7/$firstLetter/$search1" ] && echo "Directory " $search1 " exists" || mkdir "$destination7/$firstLetter/$search1"


  mv $search*pkg.tar.zst "$destination7/$firstLetter/$search1"
  mv $search*pkg.tar.zst.sig "$destination7/$firstLetter/$search1"


echo "#############################################################################################"
echo "Cleaning up"
echo "#############################################################################################"
echo "deleting unnecessary folders"
echo "#############################################################################################"

if [[ -f $wpdpath/*.log ]]; then
  rm $pwdpath/*.log
fi
if [[ -f $wpdpath/*.deb ]]; then
  rm $pwdpath/*.deb
fi
if [[ -f $wpdpath/*.tar.gz ]]; then
  rm $pwdpath/*.tar.gz
fi

tput setaf 8
echo "#############################################################################################"
echo "###################                       build done                   ######################"
echo "#############################################################################################"
tput sgr0
