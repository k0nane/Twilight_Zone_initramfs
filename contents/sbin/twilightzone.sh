#!/system/bin/sh

# Remount filesystems RW

busybox mount -o remount,rw /
busybox mount -o remount,rw /system

# Install BusyBox 1.18

/sbin/busybox --install -s /system/bin
# /sbin/busybox --install -s /sbin
sync

# Lock the CPU down til SetCPU or such can set it.

echo "1000000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo "1000000" > /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq

# Modify read_ahead_kb as per brainmaster

echo "2048" > /sys/devices/virtual/bdi/179:0/read_ahead_kb

# mkasick's recommended keyboard delay

echo "5" > /sys/devices/platform/s3c-keypad/timer_delay

# Enable init.d support

if [ -d /system/etc/init.d ]
then
	logwrapper busybox run-parts /system/etc/init.d
fi
sync

# Fix screwy ownerships

for blip in conf default.prop fota.rc init init.goldfish.rc init.rc init.smdkc110.rc lib lpm.rc modules recovery.rc res sbin
do
	chown root.system /$blip
	chown root.system /$blip/*
done

chown root.system /lib/modules/*
chown root.system /res/images/*


chmod 6755 /sbin/su
rm /system/bin/su
rm /system/xbin/su
ln -s /sbin/su /system/bin/su
ln -s /sbin/su /system/xbin/su

#setup proper passwd and group files for 3rd party root access
# Thanks DevinXtreme

if [ ! -f "/system/etc/passwd" ]; then
	echo "root::0:0:root:/data/local:/system/bin/sh" > /system/etc/passwd
	chmod 0666 /system/etc/passwd
fi
if [ ! -f "/system/etc/group" ]; then
	echo "root::0:" > /system/etc/group
	chmod 0666 /system/etc/group
fi

# fix busybox DNS while system is read-write

if [ ! -f "/system/etc/resolv.conf" ]; then
	echo "nameserver 8.8.8.8" >> /system/etc/resolv.conf
	echo "nameserver 8.8.4.4" >> /system/etc/resolv.conf
fi 
sync

# remount read only and continue
busybox mount -o remount,ro /
busybox mount -o remount,ro /system

