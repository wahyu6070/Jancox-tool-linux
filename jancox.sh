#!/bin/bash
#jancox-tool-linux
#by wahyu606070

log=./bin/jancox.log
name=`grep "jancox.name" ./bin/jancox.prop | cut -d '=' -f2`
version=`grep "jancox.version" ./bin/jancox.prop | cut -d '=' -f2`
build=`cat ./bin/jancox.prop | grep jancox.build | cut -d "=" -f 2`
author=`grep "jancox.author" ./bin/jancox.prop | cut -d '=' -f2`
date=`grep "jancox.date" ./bin/jancox.prop | cut -d '=' -f2`
database=./bin/database/database

chmod 775 ./bin/addon/7za
chmod 775 ./bin/addon/make_ext4fs
chmod 775 ./bin/addon/rimg2sdat
ext=./bin/addon/7za
img=./bin/imgdat/imgextractor.py
tmp=./bin/tmp

if [ -f ./editor/system/system/build.prop ]; then
  system=./editor/system/system
else
  system=./editor/system
fi

system-auto(){
auto1=`grep auto.decrypt $database | cut -d "=" -f 2`
auto2=`grep auto.fixperm $database | cut -d "=" -f 2`
auto3=`grep auto.debloat $database | cut -d "=" -f 2`
auto4=`grep auto.clean $database | cut -d "=" -f 2`
auto5=`grep auto.test $database | cut -d "=" -f 2`

if [ $auto1 == on ]; then
         auto=true

elif [ $auto1 == on ]; then
         auto=yes
elif [ $auto2 == on ]; then
         auto=yes
elif [ $auto3 == on ]; then
         auto=yes
elif [ $auto4 == on ]; then
         auto=yes      
elif [ $auto5 == on ]; then
         auto=yes
else
         auto=no                
fi

if [ $auto == yes ]; then
  echo " *Jancox-tool System Auto*"
  echo " "
  sleep 2s

       if [ $auto1 == on ]; then
         echo "-Auto decrypt "
         sleep 3s
       fi  
       if [ $auto2 == on ]; then
         echo "-Auto fix permissions "
         sleep 3s
       fi  
       if [ $auto3 == on ]; then
         echo "-Auto debloating app "
         sleep 3s
       fi 
       if [ $auto4 == on ]; then
        echo "-Auto cleaning cache " 
        sleep 3s
       fi       
       if [ $auto5 == on ]; then
         echo "-Auto test integration" 
         sleep 3s          
       fi

fi


}

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
      		echo "               LOG"
      		echo " "
          if [ -f $log ]; then
      		  cat $log
           else
           echo "log null" 
          fi 
     	 elif [ $anjink == 2 ]; then
         	break	
      	 else
        	echo "please select 1 or 2 !"
        	sleep 2s
      	fi
      done
  }

unpack(){
    clear
    echo "                          Unpack" | tee -a $log
    echo " " | tee -a $log
    sdat2img=./bin/imgdat/sdat2img.py
    img=./bin/imgdat/imgextractor.py
    if [ -f ./input/input.zip ]; then
      input=./input/input.zip
    elif [ -f ./input/in.zip ]; then
        input=./input/input.zip
    else
      input="$(zenity --title "Pick your ROM" --file-selection 2>/dev/null)"
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
    if [ -f $input ]; then
    echo "Extracting input.zip ..."
    $ext e "$input" n system.new.dat.br -o./bin/tmp > /dev/null
    $ext e "$input" n system.transfer.list -o./bin/tmp > /dev/null
    $ext e "$input" n vendor.new.dat.br -o./bin/tmp > /dev/null
    $ext e "$input" n vendor.transfer.list -o./bin/tmp > /dev/null
    $ext x "$input" -o./output firmware-update > /dev/null
    $ext x "$input" -o./output META-INF > /dev/null
    $ext x "$input" n boot.img -o./output > /dev/null
    else
    	echo " file zip not found " > $log
    fi
    if [ -f $tmp/system.new.dat.br ]; then
    	echo "unpack system.new.dat.br to system.new.dat..." >> $log
    	brotli -d ./bin/tmp/system.new.dat.br -o ./bin/tmp/system.new.dat
    	echo "unpack vendor.new.dat.br to vendor.new.dat..." >> $log
    	brotli -d ./bin/tmp/vendor.new.dat.br -o ./bin/tmp/vendor.new.dat
	else
		echo " system.new.dat not found " > $log
	fi
	if [ -f $tmp/system.new.dat ]; then
    	echo "unpack system.new.dat to system.img...";
    	python3 $sdat2img ./bin/tmp/system.transfer.list ./bin/tmp/system.new.dat ./bin/tmp/system.img > /dev/null
    	echo "unpack system.new.dat to vendor.img..." | tee -a $log
    	python3 $sdat2img ./bin/tmp/vendor.transfer.list ./bin/tmp/vendor.new.dat ./bin/tmp/vendor.img > /dev/null
	fi
	if [ ! -f $tmp/system.new.dat.br ]; then
		echo " searching system.img from $input"
		unzip -o $input  -d $tmp | tee -a $log
	fi	

	if [ -f $tmp/system.img ]; then
    echo "unpack system.img to system..." | tee -a $log
    sudo python3 $img ./bin/tmp/system.img ./editor/system > /dev/null
    echo "unpack vendor.img to vendor..." | tee -a $log
    sudo python3 $img ./bin/tmp/vendor.img ./editor/vendor > /dev/null
    echo "set permissions by $username..." | tee -a $log
    sudo chown -R $username:$username ./editor 2>/dev/null | tee -a $log
    sudo chown -R $username:$username ./bin/tmp 2>/dev/null | tee -a $log
	fi
    if [ -f ./editor/system/build.prop ]; then
        echo "Unpack done" | tee -a $log
    elif [ -f ./editor/system/system/build.prop ]; then
        echo "Unpack done" | tee -a $log
    else
        echo "Unpack error" | tee -a $log
    fi
    system-auto;
    back;
}

repack(){
	clear
	img2sdat=./bin/imgdat/img2sdat.py
    size1=$(cat ./editor/system_size.txt)
    size2=$(cat ./editor/vendor_size.txt)
    block=2009110000
    echo "                        REPACK " | tee -a $log
    echo " " | tee -a $log
    rm -rRf ./output > /dev/null
    mkdir ./output
    if [ -d ./editor/system ]; then
      echo "Repack from system to system.img " | tee -a $log
      ./bin/addon/make_ext4fs -s -L system -T 2009110000 -S ./bin/tmp/system_file_contexts -C ./bin/tmp/system_fs_config -l $size1 -a system ./output/system.img ./editor/system/ > /dev/null
      echo "Repack from vendor to vendor.img " | tee -a $log
      ./bin/addon/make_ext4fs -s -L vendor -T 2009110000 -S ./bin/tmp/vendor_file_contexts -C ./bin/tmp/vendor_fs_config -l $size2 -a vendor ./output/vendor.img ./editor/vendor/ > /dev/null
    elif [ -d ./editor/system ]; then
      ./bin/make_ext4fs -T 0 -S ./bin/tmp/system_file_contexts -1 2009110000 -a ./output/system.img ./editor/system/
      ./bin/make_ext4fs -T 0 -S ./bin/tmp/vendor_file_contexts -1 2009110000 -a ./output/vendor.img ./editor/vendor/
    else 
       echo "system not found" > $log  
    fi;
    if [ -f ./output/system.img ]; then
    echo "Repack from system.img to system.new.dat " | tee -a $log
    python3 $img2sdat ./output/system.img -o ./output -v 4 > /dev/null
    echo "Repack from system.img to system.new.dat " | tee -a $log
    python3 $img2sdat ./output/vendor.img -o ./output -v 4 -p vendor > /dev/null
    else
      echo system.img not found > $log
    fi  
    #level brotli
    brlvl=`grep "brotli.level" ./bin/setting.prop | cut -d '=' -f2`
    #
    if [ -f ./output/system.new.dat.br ]; then
    echo "Repack system.new.dat to system.new.dat.br  " | tee -a $log
    brotli -$brlvl ./output/system.new.dat -o ./output/system.new.dat.br
    echo "Repack vendor.new.dat to vendor.new.dat.br  " | tee -a $log
    brotli -$brlvl ./output/vendor.new.dat -o ./output/vendor.new.dat.br
    else
     echo system.new.dat.br not found > $log
    fi   
    echo cleaning  | tee -a $log
    rm -rf ./output/system.img > /dev/null
    rm -rf ./output/system.new.dat > /dev/null
    rm -rf ./output/vendor.img > /dev/null
    rm -rf ./output/vendor.new.dat > /dev/null
    if [ -f ./output/system.new.dat.br ]; then
      echo "Repack done " | tee -a $log
    else
      echo "Repack error " | tee -a $log
    fi
    back;
}
cleanup(){
     clear
     echo "                    Cleanup"
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
     echo "Cleaning editor " | tee -a $log
     sleep 1s
     rm -rf ./editor/system
     rm -rf ./editor/vendor
     rm -rf ./editor/system_size.txt
     rm -rf ./editor/vendor_size.txt
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
     rm -rRf ./output/META-INF > /dev/null
     rm -rf $tmp/system_fs_config
     rm -rf $tmp/vendor_fs_config
     echo "Cleanup done..." | tee -a $log
     back;
}
add-on(){
        dm1=`grep ro.secure ./editor/vendor/default.prop | cut -d "=" -f 2`
        dm2=$(grep forceencrypt= ./editor/vendor/etc/fstab.qcom)
        dm3=$(grep ,verify// ./editor/vendor/etc/fstab.qcom)
        dm4=$(grep forcefdeorfbe= ./editor/vendor/etc/fstab.qcom)
        dm5=$(grep fileencryption= ./editor/vendor/etc/fstab.qcom) 
        dm6=$(grep .dmverity=true ./editor/vendor/etc/fstab.qcom)
       for asw in 1 2 3 4
       do
       if [ -f $system/recovery-from-boot.p ]; then
              dm="DM-verity == enable"
       elif [ $dm1 ]; then 
              dm="DM-verity = enable"
       elif [ $dm2 ]; then 
              dm="DM-verity = enable"
       elif [ $dm3 ]; then 
              dm="DM-verity  enable"
       elif [ $dm4 ]; then 
              dm="DM-verity = enable"
       elif [ $dm5 ]; then 
              dm="DM-verity = enable" 
       elif [ $dm6 ]; then 
              dm="DM-verity = enable"     
                                       
       else
              dm="DM-verity = Disable"
       fi
       if [ -d ./editor/system/system ]; then
              sys="system as-root = true"
        else
              sys="system as-root = false"
       fi
       clear          
	       echo "                         Add-on"
         echo "   $dm  $sys  "
	       echo " "
         echo "1.Fix permissions"
         echo "2.Disable DM-verity "
         echo "3.Debloat "
         echo "4.Clean log"
         echo "5.Back to menu "
         echo " "
         echo -n "Select = "
         read add
           case $add in
               1)
                  username=$(uname -n)
                  echo " fixed permissions..." | tee -a $log
                  sleep 2s
                  chown -R $username:$username ./editor 2>/dev/null
                  chown -R $username:$username ./bin/tmp 2>/dev/null
                  chown -R $username:$username ./output 2>/dev/null
                  echo " Done " | tee -a $log
                  sleep 2s
                  ;;
               2)
                  echo " Disabling dm-verity..." | tee -a $log
                  rm -rf $system/recovery-from-boot.p
                  sed -i 's/secure=0/secure=1/g' ./editor/vendor/default.prop
                  sed -i 's/forceencrypt/encryptable/g' ./editor/vendor/etc/fstab.qcom
                  sed -i 's/,verify//g' ./editor/vendor/etc/fstab.qcom
                  sed -i 's/forcefdeorfbe/encryptable/g' ./editor/vendor/etc/fstab.qcom
                  sed -i 's/fileencryption/encryptable/g' ./editor/vendor/etc/fstab.qcom
                  sed -i 's/.dmverity=true/.dmverity=false/g' ./editor/vendor/etc/fstab.qcom

                  sleep 1s
                  echo " Done" | tee -a $log
                  sleep 3s
                 ;;
               3)
                  echo "Coming soon"
                  sleep 4s
                ;; 
               4) 
                  rm -rf $log
                  echo "Cleaning log..."
                  sleep 1s
                  echo " Done"
                  sleep 2s
                ;;

               5)
                break
                ;;
               *)
                  echo "comman not found"
                 ;; 
          esac  
        done
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
      echo "Author   = wahyu6070"
      echo "Licensed = GPL3"
      echo "Github   = https://github.com/wahyu6070"
      echo "Youtube  = https://youtube.com/c/wahyu6070"
      echo "Blog     = https://wahyu6070.blogspot.com"
      back;
}
while true in
do
  clear
    echo "      $name $version $build by $author "
    echo " "
    if [ -f $system/build.prop ]; then
    device=`cat ./editor/vendor/build.prop | grep ro.product.vendor.device | cut -d "=" -f 2`
    rom=`cat $system/build.prop | grep ro.build.display.id | cut -d "=" -f 2`
    androv=`cat $system/build.prop | grep ro.build.version.release | cut -d "=" -f 2`
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
