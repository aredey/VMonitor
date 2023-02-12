vms.sh is a bash script to be ran on a proxmox server/host/hypervisor that monitors a VM and if it is dead (locked up, lost access to the outside world, etc.) it will attempt, increasingly aggressively, to restart it.

This script can be ran interactively by root, the admin user or can be ran periodiaclly via crontab.

Example use cases:
------------------
`vms.sh` - use interactively, choose the VM to examine and restart if dead if possible

`vms.sh 305 192.168.31.244` - invoke as root to monitor the VM with a VMID of 305 and IP address  of 192.168.31.244

`15 * * * * /rooot/vms.sh 305 192.168.31.244` #my dev docker VM - ran by crontab every hour (past 15 minutes) to monitor the VM with a VMID of 305 and IP address  of 192.168.31.244

