#!/bin/bash
#jancox-tool
#by whyu6070

#sudo permissions
sudo echo

#
#util_functions

. ./bin/linux/utility.sh

#

clear
echo "                          Jancox Tool by wahyu6070"
echo " "
echo "             Unpack"
echo " "
localdir=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
bin=./bin/linux
sdat2img=$bin/sdat2img.py
img=$bin/imgextractor.py
p7za=$bin/7za
brotli=$bin/brotli 
edit=./editor
bb=./bin/linux/busybox
tmp=./bin/tmp

[ -d ./editor ] && sudo rm -rf editor; mkdir editor;
[ -d ./bin/tmp ] && sudo rm -rf ./bin/tmp; mkdir bin/tmp;
[ ! -d $tmp ] &&  mkdir $tmp;


chmod -R 777 $bin
if [ -f ./input.zip ]; then
     input=./input.zip
elif [ -f ./rom.zip ]; then
     input=./rom.zip
else
    input="$(zenity --title "Pick your ROM" --file-selection 2>/dev/null)"
fi

sleep 1s
if [ $(whoami) == root ]; then
echo -n "Username Your PC : "
read username
else
    username=$(whoami)
fi
echo "- Using input from $input "
if [ -f "$input" ]; then
echo "- Extracting input.zip ..."
$bb unzip -o "$input" -d $tmp >/dev/null
else
    echo "- File zip not found"
    exit
fi
if [ -f $tmp/system.new.dat.br ]; then
	echo "- Unpack system.new.dat.br..."
	$brotli -d $tmp/system.new.dat.br
	sudo rm -rf $tmp/system.new.dat.br
fi

if [ -f $tmp/vendor.new.dat.br ]; then	
	echo "- Unpack vendor.new.dat.br..."
	$brotli -d $tmp/vendor.new.dat.br
	sudo rm -rf $tmp/vendor.new.dat.br
fi

if [ -f $tmp/system.new.dat ]; then
    echo "- Unpack system.new.dat...";
    python3 $sdat2img $tmp/system.transfer.list $tmp/system.new.dat $tmp/system.img > /dev/null
    sudo rm -rf $tmp/system.transfer.list $tmp/system.new.dat $tmp/system.patch.dat
fi

if [ -f $tmp/vendor.new.dat ]; then
    echo "- Unpack system.new.dat...";
    python3 $sdat2img $tmp/vendor.transfer.list $tmp/vendor.new.dat $tmp/vendor.img > /dev/null
    sudo rm -rf $tmp/vendor.transfer.list $tmp/vendor.new.dat $tmp/vendor.patch.dat
fi

if [ -f $tmp/system.img ]; then
echo "- Unpack system.img..."
sudo python3 $img $tmp/system.img $edit/system > /dev/null
sudo rm -rf $tmp/system.img
fi
if [ -f $tmp/vendor.img ]; then
echo "- Unpack vendor.img..."
sudo python3 $img $tmp/vendor.img $edit/vendor > /dev/null
sudo rm -rf $tmp/vendor.img
fi
if [ -f $tmp/boot.img ]; then
    echo "- Unpack boot.img"
    $bin/magiskboot unpack $tmp/boot.img 2>/dev/null
    [ ! -d $edit/boot ] && mkdir $edit/boot
    [ -f ramdisk.cpio ] && mv ramdisk.cpio $edit/boot/
    [ -f kernel ] && mv kernel $edit/boot/
    [ -f kernel_dtb ] && mv kernel_dtb $edit/boot/
    [ -f header ] && mv header $edit/boot.info
    [ -f second ] && mv second $edit/boot/
fi


echo "- Set permissions by $username..."
sudo chown -R $username:$username $edit 2>/dev/null
sudo chown -R $username:$username $tmp 2>/dev/null
[ -f $tmp/system_file_contexts ] && mv -f $tmp/system_file_contexts $edit/
[ -f $tmp/vendor_file_contexts ] && mv -f $tmp/vendor_file_contexts $edit/
[ -f $tmp/system_fs_config ] && mv -f $tmp/system_fs_config $edit/
[ -f $tmp/vendor_fs_config ] && mv -f $tmp/vendor_fs_config $edit/
[ -f $tmp/boot.img ] && mv -f $tmp/boot.img $edit/
[ -f $tmp/compatibility.zip ] && mv -f $tmp/compatibility.zip $edit/
[ -f $tmp/compatibility_no_nfc.zip ] && mv -f $tmp/compatibility_no_nfc.zip $edit/
[ -d $tmp/install ] && mv -f $tmp/install $edit/
[ -d $tmp/firmware-update ] && mv -f $tmp/firmware-update $edit/
[ -d $tmp/META-INF ] && mv -f $tmp/META-INF $edit/
[ -d $tmp/install ] && mv -f $tmp/install $edit/
[ -d $tmp/system ] && mv -f $tmp/system $edit/system2

sleep 2s
if [ -f $edit/$system/build.prop ]; then
		sudo rm -rf $tmp >/dev/null 2>/dev/null
        echo "- Unpack done"
        echo " "
        #$bin/utility.sh rom-info | tee -a $edit/rom-info
if [ $(grep -q secure=0 $edit/vendor/default.prop) ]; then dmverity=true;
elif [ $(grep forceencrypt $edit/vendor/etc/fstab.qcom) ]; then dmverity=true;
elif [ $(grep forcefdeorfbe $edit/vendor/etc/fstab.qcom) ]; then dmverity=true;
elif [ $(grep fileencryption $edit/vendor/etc/fstab.qcom) ]; then dmverity=true;
elif [ $(grep .dmverity=true $edit/vendor/etc/fstab.qcom) ]; then dmverity=true;
elif [ $(grep fileencryption $edit/vendor/etc/fstab.qcom) ]; then dmverity=true;
#elif [ -f $edit/$system/recovery-from-boot.p ]; then dmverity=true;
else
dmverity=false
fi;
. ./bin/linux/utility.sh rom-info
else
   echo "- Unpack done"
fi
sleep 1s