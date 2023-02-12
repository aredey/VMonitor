#!/usr/bin/env bash

fn_bye() { echo "Bye."; exit 0; }
fn_fail() { echo "Non-existent option!" ; exit 1; }
fn_tryagain() { echo "Non-existent option, try again!"; }

mainmenu() {
    echo -ne "
Which VM do you want to test[ and restart]?
1) WebServices  (vmid:312 ip:192.168.61.55)
2) NewPortainer (vmid:305 ip:192.168.31.244)

0) Exit
Choose an option, which VM to check and restart:  "
    read -r ans
    case $ans in
    1)
        vmid=312
        ip=192.168.61.55
        ;;
    2)
        vmid=305
        ip=192.168.31.244
        ;;
    0)
        fn_bye
        ;;
    *)
        fn_tryagain
        mainmenu
        ;;
    esac
}

restartvm() {
  #vmid=305
  #ip=192.168.31.244
  vmid=$1
  ip=$2
  
  # might want to sanitise input... 8-|
  
  ping -c 3 $ip > /dev/null
  status=$?
  if [ $status -eq 0 ]
  then
      : echo "pinging $ip is OK: $status"
      exit 0
  else
      #echo "ping failed with $status, trying to reset VM"
      logger -t restart-docker-vm.sh  "### PING to DockerServer failed with $status, REBOOTing DockerServer VM ###"
      qm reset $vmid
      status=$?
      if [ $status -eq 0 ]
      then
          : echo "Worked, status = $status"
          exit 0
      else
          # Simple restart failed, force reset
          logger -t restart-docker-vm.sh  "### PING to DockerServer failed with $status, FORCING REBOOTing DockerServer VM ###"
          qm reset $vmid --skiplock
          status=$?
          if [ $status -eq 0 ]
          then
            : echo "Worked, status = $status"
            exit 0
          else
            logger -t restart-docker-vm.sh  "### All attemts failed with $status, killing  DockerServer and  RELAUNCHing the DockerServer VM ###"
            kill -9 `ps aux | awk '/\/usr\/bin\/kvm -id $vmid/ {print $2}'`
            sleep 5
            qm start $vmid
          fi
      fi
  fi
  exit 0
}

##### Main Program #####
#clear

if [ "$#" -eq 0 ];
then
  # Use interactive menu to choose the "ip" and "vmid", and test and if required restart VM
  mainmenu
  restartvm $vmid $ip 
elif [ "$#" -gt 2 ] || [ "$#" -eq 1 ];
then
  # Wrong number of command line arguments, exit cleanly
  echo -ne "Usage: $0 <VMID> <IP address>\n"
  qm list
  echo -ne "\nVM NAME\t\tSTATUS\t\tIP ADDRESS\n"
  ip -br a
  exit 1
else
  # Both "vmid" and "ip" address have been supplied
  # ok to do the testing and restarting of VM (assuming they are sensible)
  restartvm $1 $2
fi
