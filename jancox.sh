#!/bin/bash
#jancox-tool-linux
#by wahyu606070

log=./bin/jancox.log
name=`grep "jancox.name" ./bin/jancox.prop | cut -d '=' -f2`
version=`grep "jancox.version" ./bin/jancox.prop | cut -d '=' -f2`
build=`cat ./bin/jancox.prop | grep jancox.build | cut -d "=" -f 2`
author=`grep "jancox.author" ./bin/jancox.prop | cut -d '=' -f2`
date=`grep "jancox.date" ./bin/jancox.prop | cut -d '=' -f2`

chmod 775 ./bin/addon/7za
chmod 775 ./bin/addon/make_ext4fs
chmod 775 ./bin/addon/rimg2sdat
ext=./bin/addon/7za
img=./bin/imgdat/imgextractor.py

if [ -f ./editor/system/system/build.prop ]; then
  system=./editor/system/system
else
  system=./editor/system
fi

back(){

      for anjink in "1" "2"
      do
      	echo " ____________________________ "
      	echo "|                           |"
        echo "|1.Read log    2.Back menu  |"
        echo "|___________________________|"
        echo " "
      	echo -n "select 1 or 2 = "
      	read anjink
      	if [ $anjink == 1 ]; then
      		cat $log
     	 elif [ $anjink == 2 ]; then
         	break	
      	 else
        	echo "please select 1 or 2 !"
        	sleep 2s
      	fi
      done
  }

unpack(){
    sdat2img=./bin/imgdat/sdat2img.py
    img=./bin/imgdat/imgextractor.py
    if [ -f ./input/input.zip ]; then
      input=./input/input.zip
    elif [ -f ./input/in.zip ]; then
        input=./input/input.zip
    else
      input="$(zenity --title "Pick your ROM" --file-selection)"
    fi
    echo "using input from $input " | tee -a $log
    sleep 2s
    rm -rf ./editor
    rm -rf ./bin/tmp
    rm -rf ./output/META-INF
    rm -rf ./output/firmware-update
    rm -rf ./output/boot.img
    mkdir ./editor
    mkdir ./bin/tmp
    sudo echo permissions sudo >> $log
    username=$(uname -n)
    echo username = $username >> $log
    echo "Extracting input.zip ..."
    $ext e "$input" n system.new.dat.br -o./bin/tmp > /dev/null
    $ext e "$input" n system.transfer.list -o./bin/tmp > /dev/null
    $ext e "$input" n vendor.new.dat.br -o./bin/tmp > /dev/null
    $ext e "$input" n vendor.transfer.list -o./bin/tmp > /dev/null
    $ext x "$input" -o./output firmware-update > /dev/null
    $ext x "$input" -o./output META-INF > /dev/null
    $ext x "$input" n boot.img -o./output > /dev/null
    echo "unpack system.new.dat.br to system.new.dat..." >> $log
    brotli -d ./bin/tmp/system.new.dat.br -o ./bin/tmp/system.new.dat
    echo "unpack vendor.new.dat.br to vendor.new.dat..." >> $log
    brotli -d ./bin/tmp/vendor.new.dat.br -o ./bin/tmp/vendor.new.dat
    echo "unpack system.new.dat to system.img...";
    python3 $sdat2img ./bin/tmp/system.transfer.list ./bin/tmp/system.new.dat ./bin/tmp/system.img > /dev/null
    echo "unpack system.new.dat to vendor.img..." | tee -a $log
    python3 $sdat2img ./bin/tmp/vendor.transfer.list ./bin/tmp/vendor.new.dat ./bin/tmp/vendor.img > /dev/null
    echo "unpack system.img to system..." | tee -a $log
    sudo python3 $img ./bin/tmp/system.img ./editor/system > /dev/null
    echo "unpack vendor.img to vendor..." | tee -a $log
    sudo python3 $img ./bin/tmp/vendor.img ./editor/vendor > /dev/null
    echo "set permissions by $username..." | tee -a $log
    sudo chown -R $username:$username ./editor
    sudo chown -R $username:$username ./bin/tmp
    if [ -f ./editor/system/build.prop ]; then
        echo "Unpack done" | tee -a $log
    elif [ -f ./editor/system/system/build.prop ]; then
        echo "Unpack done" | tee -a $log
    else
        echo "Unpack error" | tee -a $log
    fi
    back;
}

repack(){
	img2sdat=./bin/imgdat/img2sdat
    size1=$(cat ./editor/system_size.txt)
    size2=$(cat ./editor/vendor_size.txt)
    block=2009110000
    echo " $jancoxv " | tee -a $log
    echo " "
    rm -rRf ./output
    mkdir ./output
    echo "Repack from system to system.img " | tee -a $log
    if [ -d ./editor/system ]; then
      ./bin/addon/make_ext4fs -s -L system -T 2009110000 -S ./bin/tmp/system_file_contexts -C ./bin/tmp/system_fs_config -l $size1 -a system ./output/system.img ./editor/system/ 2>/dev/null
      echo "Repack from vendor to vendor.img " | tee -a $log
      ./bin/addon/make_ext4fs -s -L vendor -T 2009110000 -S ./bin/tmp/vendor_file_contexts -C ./bin/tmp/vendor_fs_config -l $size2 -a vendor ./output/vendor.img ./editor/vendor/ 2>/dev/null
    elif [ -d ./editor/system ]; then
      ./bin/make_ext4fs -T 0 -S ./bin/tmp/system_file_contexts -1 2009110000 -a ./output/system.img ./editor/system/
      ./bin/make_ext4fs -T 0 -S ./bin/tmp/vendor_file_contexts -1 2009110000 -a ./output/vendor.img ./editor/vendor/
    fi;
    echo "Repack from system.img to system.new.dat " | tee -a $log
    python3 $img2sdat ./output/system.img -o ./output -v 4 > /dev/null
    echo "Repack from system.img to system.new.dat " | tee -a $log
    python3 $img2sdat ./output/vendor.img -o ./output -v 4 -p vendor 2>/dev/null
    #level brotli
    brlvl=`grep "brotli.level" ./bin/setting.prop | cut -d '=' -f2`
    #
    echo "Repack system.new.dat to system.new.dat.br  " | tee -a $log
    brotli -$brlvl ./output/system.new.dat -o ./output/system.new.dat.br
    echo "Repack vendor.new.dat to vendor.new.dat.br  " | tee -a $log
    brotli -$brlvl ./output/vendor.new.dat -o ./output/vendor.new.dat.br
    echo "cleaning " | tee -a $log
    rm -rf ./output/system.img
    rm -rf ./output/system.new.dat
    rm -rf ./output/vendor.img
    rm -rf ./output/vendor.new.dat
    if [ -f ./output/system.new.dat.br ]; then
      echo "Repack done " | tee -a $log
    else
      echo "Repack error " | tee -a $log
    fi
    back;
}
cleanup(){
     echo "cleaning tmp " | tee -a $log
     sleep 1s
     rm -rRf ./bin/tmp/system.img > /dev/null
     rm -rRf ./bin/tmp/system.new.dat > /dev/null
     rm -rRf ./bin/tmp/system.new.dat.br > /dev/null
     rm -rRf ./bin/tmp/system.transfer.list > /dev/null
     rm -rRf ./bin/tmp/system_file_contexts > /dev/null
     rm -rRf ./bin/tmp/vendor.img > /dev/null
     rm -rRf ./bin/tmp/vendor.new.dat > /dev/null
     rm -rRf ./bin/tmp/vendor.new.dat.br > /dev/null
     rm -rRf ./bin/tmp/vendor.transfer.list > /dev/null
     rm -rRf ./bin/tmp/vendor_file_contexts > /dev/null
     echo "cleaning editor " | tee -a $log
     sleep 1s
     rm -rf ./editor/system
     rm -rf ./editor/vendor
     rm -rf ./editor/system_size.txt
     rm -rf ./editor/system_size.txt
     echo "cleaning output " | tee -a $log
     sleep 1s
     rm -rRf ./output/system.img > /dev/null
     rm -rRf ./output/system.new.dat > /dev/null
     rm -rRf ./output/system.new.dat.br > /dev/null
     rm -rRf ./output/system.transfer.list > /dev/null
     rm -rRf ./output/system.patch.dat > /dev/null
     rm -rRf ./output/vendor.img > /dev/null
     rm -rRf ./output/vendor.new.dat > /dev/null
     rm -rRf ./output/vendor.new.dat.br > /dev/null
     rm -rRf ./output/vendor.transfer.list > /dev/null
     rm -rRf ./output/vendor.patch.dat > /dev/null
     rm -rRf ./output/firmware > /dev/null
     rm -rRf ./output/META-INF > /dev/null
     echo "Cleanup done..." | tee -a $log
     back;
}
add-on(){
	clear
	echo "                         Add-on"
	echo " "
        echo "Coming soon "
       back;
}

setting(){
  brotlilvl=`grep "brotli.level" ./bin/setting.prop | cut -d '=' -f2`
  clear
  echo "                           Setting "
  echo " "
  echo "Brotli level = $brotlilvl " | tee -a $log
  back;


}
about(){
	  clear
	  echo "                       About"
	  echo " "
      echo "$name $version ($build $date) multi-call binary."
      sleep 1s
      echo "Author   = wahyu6070"
      sleep 1s
      echo "Licensed = GPL3"
      sleep 1s
      echo "Github   = https://github.com/wahyu6070"
      sleep 1s
      echo "Youtube  = https://youtube.com/c/wahyu6070"
      sleep 1s
      echo "Blog     = https://wahyu6070.blogspot.com"
      sleep 1s
      back;
}
menu(){
	clear
    echo " "
	echo "      $name $version $build by $author "
    echo " "
    if [ -f $system/build.prop ]; then
    device=`cat $system/build.prop | grep ro.product.system.device | cut -d "=" -f 2`
    rom=`cat $system/build.prop | grep ro.product.system.model | cut -d "=" -f 2`
    androv=`cat $system/build.prop | grep ro.system.build.version.release | cut -d "=" -f 2`
    echo "Rom     = $rom"
    echo "Android = $androv"
    echo "Device  = $device"
    fi
    echo " "
	echo "1.Unpack"
	echo "2.Repack"
    echo "3.Cleanup"
    echo "4.Add on"
    echo "5.Setting"
	echo "6.About"
	echo "7.Exit"
	echo " "
    echo -n "select number : "
	read memek
    echo " "
}
while true in
do
menu;
  case $memek in
    1) unpack
       ;;
    2) repack
       ;;
    3) cleanup
       ;;
    4) add-on
       ;;
    5) setting
       ;;
    6) about
       ;;
    7)
      echo exit >> $log
      clear
      break

      ;;
    *)
      echo "command not found" | tee -a $log
      ;;
   esac
done
