#!/bin/bash

source config.conf

##php makeRouterBackup.php
light_red='\e[1;91m%s\e[0m\n'
light_green='\e[1;92m%s\e[0m\n'

function backup {
	echo -ne "$2 \t"
	name=`echo $2 | xargs`
    ping -c 1 -w 1 -q $1 > /dev/null 2>&1
    if [ "$?" -eq 0 ]; then
##	printf "$light_green" "[ CONNECTION AVAILABLE ]"
	ver=`ssh -oBatchMode=yes $USER@$1 "/system resource print" | grep version | awk  -F '[/:]' '{print $2}' | tr -d '\r'`
	echo -ne "\t $ver"
	cur=`ssh -oBatchMode=yes $USER@$1 "/system routerboard print" | grep current | awk  -F '[/:]' '{print $2}' | tr -d '\r'`
	echo -ne "\t $cur"
	bb=`ssh -oBatchMode=yes $USER@$1 "/system resource print" | grep bad-blocks | awk  -F '[/:]' '{print $2}' | tr -d '\r'`
	echo -ne "\t\t $bb \n"
##	ssh -oBatchMode=yes $USER@$1 "/system resource print" | grep load
	## vytvor slozku pokud neexistuje
	if [ -d "zalohy/$name" ]; then rm -Rf zalohy/$name; fi
	mkdir -p zalohy/$name/files
	ssh -oBatchMode=yes $USER@$1 "/export verbose file=$name.rsc; /system backup save dont-encrypt=yes name=$name" > /dev/null 2>&1
	## tichy prenos vygenerovanych souboru
	scp -q -B $USER@$1:/$name.rsc zalohy/$name/$name.rsc 
	scp -q -B $USER@$1:/$name.backup zalohy/$name/$name.backup 
	ssh -oBatchMode=yes $USER@$1 "/file remove $name.rsc; /file remove $name.backup"
	if [ "$name" == "TheDude_______" ]; then
	    ssh -oBatchMode=yes $USER@$1 "/dude export-db backup-file=$name" > /dev/null 2>&1
	fi
	## tichy prenos vsech ostatnich souboru -q -r
	## puvodni reseni bezpecne ale nefunkcni scp -B -r $USER@$1:/ zalohy/$name/files/
	wget -q -r -nH -P zalohy/$name/files ftp://$1/* --ftp-user=$USER --ftp-password=$PASS
	if [ "$name" == "TheDude_______" ]; then
	    ssh -oBatchMode=yes $USER@$1 "/file remove $name"
	fi
    else                                              
	printf "$light_red" "[ HOST DISCONNECTED ]"
	echo $name nebylo mozne zalohovat neni ping na $1!
    fi
}

echo "Zalohovani jednotlivych RB s vypisem verzi a Bad Blocks"
echo "Pojmenovani   		verze package		vezre firmware		bad blocks"
backup 192.168.133.252 "TheDude_______"
backup 192.168.133.254 "Iris__________"
echo "___Pobocky______________________"
backup 192.168.11.200 "Kukleny_______"
backup 192.168.12.200 "Malsovice_____"
backup 192.168.13.200 "Slezske_______"
backup 192.168.15.200 "NHK___________"
backup 192.168.16.200 "Labska________"
backup 192.168.17.200 "MPB___________"
backup 192.168.19.200 "MPA___________"
backup 192.168.22.200 "Plotiste______"
backup 192.168.24.200 "Placice_______"
backup 192.168.25.200 "Brezhrad______"
echo "--------------------------------------"
backup 192.168.20.254 "Kosicky_______"
backup 10.107.193.26  "Kosicky-Antena"

echo "-----------------------------------"
echo "Duplicity - verzovani zaloh"
echo "-----------------------------------"
if mountpoint -q /mnt/backups; then
	umount /mnt/backups
fi
mount /mnt/backups
duplicity remove-all-but-n-full 3 --no-print-statistics --verbosity error file:///mnt/backups/OFFLINE/Mikrotiky/duplicity
duplicity --no-print-statistics --verbosity error --full-if-older-than 30D --no-encryption zalohy file:///mnt/backups/OFFLINE/Mikrotiky/duplicity
RemoveOld=$( duplicity remove-all-but-n-full 3 --no-print-statistics --verbosity error file:///mnt/backups/OFFLINE/Mikrotiky/duplicity 2>&1 | head -n 1 )

if [[ "$RemoveOld" != "Backup source directory remove-all-but-3-full does not exist." ]]; then
	echo $RemoveOld
fi
echo "-----------------------------------"
echo "Rsync - zkopirovani aktualni zalohy"
echo "-----------------------------------"
cd zalohy
rsync -azh --archive --delete-during . /mnt/backups/OFFLINE/Mikrotiky/AktualniZalohy
cd ..
umount /mnt/backups

##read -n 1 -s -r -p "Press any key to continue"
