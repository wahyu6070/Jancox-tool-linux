#!/bin/bash
#
#by wahyu606070

log=./bin/sur.log
profile=`cat ./bin/sur.prop | grep sur.profile | cut -d "=" -f 2`
device=`cat $system/build.prop | grep ro.product.system.device | cut -d "=" -f 2`
zap=./bin/7za
chmod 777 $zap
if [ -f ./editor/system/system/build.prop ]; then
   system=./editor/system/system
else
   system=./editor/system
fi    	

unpack(){
    img2sdat=./bin/dat/img2sdat
    sdat2img=./bin/dat/sdat2img.py
    img=./bin/img/imgextractor.py
    rm -rf ./editor
    rm -rf ./bin/tmp
    rm -rf ./output/boot.img
    rm -rf ./output/META-INF
    rm -rf ./output/firmware-update
    mkdir ./editor
    mkdir ./bin/tmp
    if [ -f ./input.zip ]; then
        input=./input.zip
    else
       input="$(zenity --title "Pick your ROM" --file-selection --gtk-no-debug=FLAGS)" > /dev/null
    fi
    
    sudo echo permissions sudo >> $log
    username=$(uname -n)
    echo username = $username >> $log
    echo "Extracting $input ..."
    echo "Username your pc : $username"
    $zap e "$input" n system.new.dat.br -o./bin/tmp > /dev/null
    $zap e "$input" n system.transfer.list -o./bin/tmp > /dev/null
    $zap e "$input" n vendor.transfer.list -o./bin/tmp > /dev/null
    $zap e "$input" n vendor.new.dat.br -o./bin/tmp > /dev/null
    $zap x "$input" -o./output firmware-update > /dev/null
    $zap x "$input" -o./output META-INF > /dev/null
    $zap x "$input" n boot.img -o./output > /dev/null
    echo "unpack system.new.dat.br to system.new.dat..." >> $log
    brotli -d ./bin/tmp/system.new.dat.br -o ./bin/tmp/system.new.dat
    echo "unpack vendor.new.dat.br to vendor.new.dat..." >> $log
    brotli -d ./bin/tmp/vendor.new.dat.br -o ./bin/tmp/vendor.new.dat
    echo "unpack system.new.dat to system.img...";
    python3 $sdat2img ./bin/tmp/system.transfer.list ./bin/tmp/system.new.dat ./bin/tmp/system.img > /dev/null
    echo "unpack system.new.dat to vendor.img..." | tee -a $log
    python3 $sdat2img ./bin/tmp/vendor.transfer.list ./bin/tmp/vendor.new.dat ./bin/tmp/vendor.img > /dev/null
    echo "unpack system.img to system..." | tee -a $log
    sudo python3 ./bin/img/imgextractor.py ./bin/tmp/system.img ./editor/system > /dev/null
    echo "unpack vendor.img to vendor..." | tee -a $log
    sudo python3 ./bin/img/imgextractor.py ./bin/tmp/vendor.img ./editor/vendor > /dev/null
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
    while true
    do 
        echo " "
        echo "1.back menu"
        echo -n "select command : "
        read anjink
        if [ $anjink == 1 ]; then
            break
        else
           echo "comman not found"
        fi  

     done
}

repack(){
    size1=$(cat ./editor/system_size.txt)
    size2=$(cat ./editor/vendor_size.txt)
    echo " $jancoxv " | tee -a $log
    echo " "
    rm -rRf ./output
    mkdir ./output
    chmod 777 ./bin/make_ext4fs
    echo "Repack from system to system.img " | tee -a $log
    ./bin/make_ext4fs -s -L system -T 2009110000 -S ./bin/tmp/system_file_contexts -C ./bin/tmp/system_fs_config -l $size1 -a system ./output/system.img ./editor/system/ > /dev/null
    echo "Repack from vendor to vendor.img " | tee -a $log
    ./bin/make_ext4fs -s -L vendor -T 2009110000 -S ./bin/tmp/vendor_file_contexts -C ./bin/tmp/vendor_fs_config -l $size2 -a vendor ./output/vendor.img ./editor/vendor/ > /dev/null
    echo "Repack from system.img to system.new.dat " | tee -a $log
    python3 ./bin/dat/img2sdat.py ./output/system.img -o ./output -v 4 > /dev/null
    echo "Repack from system.img to system.new.dat " | tee -a $log
    python3 ./bin/dat/img2sdat.py ./output/vendor.img -o ./output -v 4 -p vendor > /dev/null
    #level brotli
    brlvl=$(cat ./bin/brotli.lvl)
    #
    echo "Repack system.new.dat to system.new.dat.br  " | tee -a $log
    brotli -6 ./output/system.new.dat -o ./output/system.new.dat.br
    echo "Repack vendor.new.dat to vendor.new.dat.br  " | tee -a $log
    brotli -6 ./output/vendor.new.dat -o ./output/vendor.new.dat.br
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
    sleep 10s
}
cleanup(){
     echo "cleaning tmp " | tee -a $log
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
     rm -rf ./bin/jancox-tool.log
     echo "Cleanup done " | tee -a $log
     sleep 4s
}
about(){
    date=`cat ./bin/sur.prop | grep sur.date | cut -d "=" -f 2`
    author=`cat ./bin/sur.prop | grep sur.author | cut -d "=" -f 2`
	echo " " | tee -a $log
    echo "   $profile $date" | tee -a $log
    echo " Author = $author  " | tee -a $log
    echo " " | tee -a $log
    sleep 5s
}
menu(){
	clear
    echo " "
	echo "                       $profile "
    echo " "
    if [ -f $system/build.prop ]; then
     device=`cat $system/build.prop | grep ro.product.system.device | cut -d "=" -f 2`
     rom=`cat $system/build.prop | grep ro.product.system.model | cut -d "=" -f 2`
     androv=`cat $system/build.prop | grep ro.system.build.version.release | cut -d "=" -f 2`
     echo "Rom     = $rom (android $androv "
     echo "Device  = $device"
    fi 
    echo " "
	echo "1.Unpack   2.Repack   3.Cleanup   4.Add on   5.About   6.Exit "
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
    4) echo " null"
      sleep 4s
    ;;

    5) about
    ;;
    6)
      echo exit >> $log
      break
      ;;
    *)
      echo "command not found" | tee -a $log
      ;;
   esac
done
