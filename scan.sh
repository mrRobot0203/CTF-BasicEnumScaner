#!/bin/bash

function map(){
        mkdir nmap 2> /dev/null
        nmap -A -Pn -p- -vvv $1 > nmap/nmap.nmap 2>&1 &
        nmappid=$!

}

function gobu(){
        mkdir gobuster 2> /dev/null
        gobuster dir --url http://$1 -x php,html,txt,js -w=/usr/share/wordlists/SecLists/Discovery/Web-Content/raft-small-words.txt > gobuster/go.out 2>&1 &
        gobusterpid=$!
        ffuf -w /usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-110000.txt -u http://$1/ -H "Host:FUZZ.$1" > gobuster/gobns.out 2>&1 &
        gubustersubpid=$!
}

function what(){
        mkdir whatweb 2> /dev/null
        whatweb -a 4 -v $1 > whatweb.txt 2>&1 &
        whatwebpid=$!
}

if [ $# -eq 0 ] 
 then
 echo "no ip given"
 echo 'usage: scan.sh [ip]' 
 exit 0
fi

echo "[+] Starting nmap scan [+]"
map $1
echo "[+] staring gobuster on base address: http://$1/ [+]"
gobu $1
echo "[+] starting whatweb scan [+]"
what $1

pids=4
nmapFin=false
gobuFin=false
gobuDNSFin=false
whatFin=false


while [[ $pids -ne 0 ]]
 do
  if ! $nmapFin
   then
    if ! ps -p "$nmappid" > /dev/null 
     then
      nmapFin=true
      echo "[+] nmap scan completed [+]"
      ((pids--))
    fi
  fi
 if ! $gobuFin
  then
   if ! ps -p "$gobusterpid" > /dev/null 
    then
     gobuFin=true
     echo "[+] gubuster dir scan completed [+]"
     ((pids--))
    fi
   fi
if ! $gobuDNSFin
 then
  if ! ps -p "$gubustersubpid" > /dev/null 
   then
    gobuDNSFin=true
    echo "[+] gobuster dns scan completed [+]"
    ((pids--))
   fi
 fi
if ! $whatFin
 then
  if ! ps -p "$whatwebpid" > /dev/null 
   then
    whatFin=true
    echo "[+] whatweb scan completed [+]"
    ((pids--))
  fi
 fi
done

echo "[*] all scans completed. results in: $(pwd)/nmap, $(pwd)/gobuster and $(pwd)/whatweb [*]"
