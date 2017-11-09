# Openwrt_CC_Krack_wpad-mini

wpad-mini package binary (https://github.com/kukulo2011/Openwrt_CC_Krack_wpad-mini/blob/master/openwrt_krack_update_15.01_AR71XX.tar.gz) for the Chaos Calmer 15.05.1 and firmwares - Openwrt15.05.1 with the new wpad-mini binary for TL-WR841N with Openvpn and Krack update.

usage for wpad-mini package: download tar, extract, push with scp to your router and update with opkg install wpad-mini....ipk

usage for firmware files: factory firmwares are for flashing Openwrt from original firmware,
                          sysupgrade firmwares are for flashing from previous Openwrt version
                          

wr841n-build.sh is the build script for the firmware with Krack update

This file contains the Krackattack patches for the wifi.

Be sure your router is AR71xx architecture. If it is not or you are unsure, do not use this package - might brick your router.

Code reference used to build the wpad-mini package: git clone -b chaos_calmer git://github.com/openwrt/openwrt.git
       
After that build the package according to: https://wiki.openwrt.org/doc/howtobuild/single.package

Used package names to build the wpad-mini: libnl-tiny, hostapd
