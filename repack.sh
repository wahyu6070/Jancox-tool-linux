#!/bin/bash
#jancox tool
#by wahyu6070

#util functions
. ./bin/linux/utility.sh

#
localdir=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
out=./output
tmp=./bin/tmp
bin=./bin/linux
prop=./bin/jancox.prop
clear
if [ ! -d $edit/system ]; then echo "  Please Unpack !"; sleep 3s; exit;fi;
echo "                        Jancox Tool by wahyu6070"
echo "       Repack "
echo " "
$bin/utility.sh rom-info
echo " "
[ ! -d $tmp ] && mkdir $tmp
if [ -d $edit/system ]; then
echo "- Repack system"
size1=`du -sk $edit/system | awk '{$1*=1024;$1=int($1*1.05);printf $1}'`
$bin/make_ext4fs -s -L system -T 2009110000 -S $edit/system_file_contexts -C $edit/system_fs_config -l $size1 -a system $tmp/system.img $edit/system/ > /dev/null
fi

if [ -d $edit/vendor ]; then
echo "- Repack vendor"
size2=`du -sk $edit/vendor | awk '{$1*=1024;$1=int($1*1.05);printf $1}'`
$bin/make_ext4fs -s -L vendor -T 2009110000 -S $edit/vendor_file_contexts -C $edit/vendor_fs_config -l $size2 -a vendor $tmp/vendor.img $edit/vendor/ > /dev/null
fi;


if [ -f $tmp/system.img ]; then
 		echo "- Repack system.img"
 		[ -f $tmp/system.new.dat ] && rm -rf tmp/system.new.dat
 		python3 $bin/img2sdat.py $tmp/system.img -o $tmp -v 4 > /dev/null
 		[ -f $tmp/system.img ] && rm -rf $tmp/system.img
fi

if [ -f $tmp/vendor.img ]; then
		echo "- Repack vendor.img "
		[ -f $tmp/vendor.new.dat ] && rm -rf tmp/vendor.new.dat
		python3 $bin/img2sdat.py $tmp/vendor.img -o $tmp -v 4 -p vendor > /dev/null
		[ -f $tmp/vendor.img ] && rm -rf $tmp/vendor.img
fi

#level brotli
brlvl=$(getprop brotli.level bin/jancox.prop)
#
if [ -f $tmp/system.new.dat ]; then
    echo "- Repack system.new.dat"
    [ -f $tmp/system.new.dat.br ] && rm -rf $tmp/system.new.dat.br
	$bin/brotli -$brlvl -j -w 24 $tmp/system.new.dat -o $tmp/system.new.dat.br
fi

if [ -f $tmp/vendor.new.dat ]; then
	[ -f $tmp/vendor.new.dat.br ] && rm -rf $tmp/vendor.new.dat.br
	echo "- Repack vendor.new.dat"
	$bin/brotli -$brlvl -j -w 24 $tmp/vendor.new.dat -o $tmp/vendor.new.dat.br
fi

if [ -d $edit/boot ] && [ -f $edit/boot.img ]; then
		echo "- Repack boot"
		[ -f editor/boot/kernel ] && cp -f $edit/boot/kernel ./
		[ -f editor/boot/kernel_dtb ] && cp -f $edit/boot/kernel_dtb ./
		[ -f editor/boot/ramdisk.cpio ] && cp -f $edit/boot/ramdisk.cpio ./
		[ -f editor/boot/second ] && cp -f $edit/boot/second ./
		$bin/magiskboot repack $edit/boot.img >/dev/null 2>/dev/null
		sleep 1s
		[ -f new-boot.img ] && mv -f ./new-boot.img $tmp/boot.img
		rm -rf kernel kernel_dtb ramdisk.cpio second >/dev/null 2>/dev/null
fi

[ -d $edit/META-INF ] && cp -a $edit/META-INF $tmp/
[ -d $edit/install ] && cp -a $edit/install $tmp/
[ -d $edit/system2 ] && cp -a $edit/system2 $tmp/system
[ -d $edit/firmware-update ] && cp -a $edit/firmware-update $tmp/
[ -f $edit/compatibility.zip ] && cp -f $edit/compatibility.zip $tmp/
[ -f $edit/compatibility_no_nfc.zip ] && cp -f $edit/compatibility_no_nfc.zip $tmp/

datefile=$(getprop date.file.rom ./bin/jancox.prop)
touch -cd $datefile 15:00:00 $tmp/*
touch -cd $datefile 15:00:00 $tmp/firmware-update/*
touch -cd $datefile 15:00:00 $tmp/META-INF/com/android/*
touch -cd $datefile 15:00:00 $tmp/META-INF/com/google/android/*


if [ -d $tmp/META-INF ]; then
	echo "- Zipping"
	[ -f ./new_rom.zip ] && rm -rf ./new_rom.zip
	$bin/7za a -tzip new_rom.zip $tmp/*  >/dev/null 2>/dev/null
fi


if [ -f ./new_rom.zip ]; then
      [ -d $tmp ] && rm -rf $tmp
      echo "- Repack done"
else
      echo "- Repack error"
fi
