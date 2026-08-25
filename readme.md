# TalOS homelab setup


## prerequisites
### 01 Download Talos iso
I used [this](https://factory.talos.dev/?arch=amd64&platform=metal&schematic-id=22a73b21ea2e27057f17a22b56fdf89e09868979c10d22f10a9b7e9c1e988a60&target=metal&version=1.13.9)
- version 1.13.9 (newest)
- intel-ucode extension for intel processor
- iscsi-tools extension for longhorn

### 02 flash to usb

find usb
```
lsblk -o NAME,SIZE,MODEL,TRAN
```

unmount if any
``` 
sudo umount /dev/sda[123] 2>/dev/null
```

flash
```
sudo dd if=metal-amd64.iso of=/dev/sda bs=4M status=progress oflag=sync
```

### 03 boot from usb
boot

### 04 Find IP of Talos machine 
> *From another machine on the same network:*

#### find your local network subnet
```
ip -4 addr show
```
Look for `inet 192.168.0.31/24` or similar

#### search the network for an open port 50000
```
nmap -p 50000 --open -Pn 192.168.1.0/24
```

### 05 Test talosctl connection
```
talosctl version --nodes 192.168.0.36 --insecure
```


### 06 reserve IP
For one node, its easiest to do it though the router UI: 

```
http://192.168.0.1/
```

### 07 find disk to use
```
talosctl get disks --nodes 192.168.0.36 --insecure
```
### 08 create tfvars
```
cp terraform.tfvars.example terraform.tfvars
```
edit the vars not matching your setup.


### 09 tf plan and apply

If you want to take out the bootable usb while reboot, you can run a `ping` while applying to know then your Talos machine is rebooting.
```
ping 192.168.0.36 
```