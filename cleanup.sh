#!/bin/bash
#jancox-tool
#by wahyu6070

if [ ! -O editor ] && [ -d editor ] && [ ! -w editor]; then sudo=sudo; fi;

if [ ! $1 ]; then
	echo "               Jancox-Tool-Linux"
	echo " "
	echo "- Cleaning..."
	$sudo rm -rf editor new_rom.zip >/dev/null
	$sudo rm -rf ./bin/tmp 2>/dev/null
	echo "- Done"
	sleep 1s
fi
    