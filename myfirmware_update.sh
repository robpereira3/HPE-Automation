#!/bin/bash

# Custom shell script to install offline firmware
#  Created by KDuerr - initial code 11/17/2013
#  Modified by Robert Pereira - 05/21/2015
#  Note:  This script expecs STK of 9.60 or greater!!! (Feb 2014)

VERSION="20150423"
stty echoe -echoprt


## Internal Variables, do not modify
export TOOLKIT=/TOOLKIT
export PROFILE_MNT=/mnt/nfs
export HWDISC_FILE=/tmp/hpdiscovery.xml
export SERVERNAME
export PRODUCT_NAME
export PARM=$1
shopt -s nocasematch  # Turn case sensitivity off

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
    echo "** Trapped CTRL-C by bash shell script - exit script..."
    exit
}

# BB: The if clause is syntactically incorrect - single [ and double ]]. I doubt the shell
#     would allow that
# BB: I think the intention here is -n $PARM -a $PARM != "test" -a ....
# BB: Note I use != instead of =~. The =~ operator means "match". You really want to check
# BB: if the parameter has none of the below values
# BB: The way it is written here, the if condition is unlikely to be ever true
if [ ! -n "$PARM" -a "$PARM" =~ "test" -a "$PARM" =~ "nopre"  -a "$PARM" =~ "ask" ]] ; then
  echo -e " "
  echo -e " Unexpected parm.... \"$PARM\""
  echo -e " Valid parms:"
  echo -e "   \"ask\"    prompt for the model number "
  echo -e "   \"nopre\"  tell the script to NOT do any pre-checks or settings "
  echo -e "   \"test\"   for testing "
  echo -e " "
  exit
fi
  
  
clear
# BB: No need for the "-e" below; it is only needed if you have special characters
#     in the string
echo -e " "
echo -e "*** Upgrading Firmware - HP Proactive Services ***"
echo -e " "
echo -e "     Offline firmware custom  ISO ($VERSION)"
echo -e " "
echo -e "     Parm = \"$PARM\" "
echo -e " To STOP this utility, press Ctrl-C at any time to abort the ISO... "

if [[ "$PRODUCT_NAME" =~ "VMware Virtual Platform" || "$PARM" =~ "test"  ]] ; then
  TESTING_ONLY=true
fi

if [[ "$PRODUCT_NAME" =~ "VMware Virtual Platform" || "$PARM" =~ "test" || "$PARM" =~ "ask" ]] ; then

# BB: Rather than asking the user for a free-form product name, why don't you implement
# BB: a menu that they can pick from? Makes it much easier to specify the platform.

  echo " "
  echo " Running script on a VM or ASK, please enter PRODUCT Name to emulate. "
  echo "  Example: ProLiant DL580   Gen8"
  echo "           ProLiant DL380p  Gen8"
  echo "           ProLiant DL385   Gen8"
  echo "           ProLiant BL465c  Gen8"
  echo "           ProLiant BL660c  Gen8"
 echo " "
  read -p " Product Name: " PRODUCT_NAME
  echo " "
fi

##############################################################################
#########                                                    #################
#########  CUSTOM LIST OF PACKAGES  per   hardware PLATFORM  #################
#########                                                    #################
##############################################################################
# Note - VMware Virtual Platform is only for testing of this script.... kd

if [[ "${PRODUCT_NAME}" =~ "ProLiant DL580 Gen8" || "${PRODUCT_NAME}" =~ "ProLiant DL580 Gen8" ]]; then

    ######### Preserve this width for screen formatting of description  ###############
    #                      |                                                          |
   
    package_description[1]='DL580 Gen8 BIOS(P79) Version 1.60_11-26-2014(30 Mar 2015) '
    sp_package_filename[1]='hp-firmware-system-p79-1.60_11_26_2014-1.1.i386.rpm'

    REBOOT_VIA_COLDBOOT="Yes"
    package_description[2]='DL580G8 PowerMgmtCtrl Version 4.1 (D)       (30 Mar 2015) '
    sp_package_filename[2]='hp-firmware-powerpic-dl580-4.1-4.i386.rpm'

    package_description[3]='SmartArray/P830i(Critical) Version 2.40      (06 Apr 2015)'
    sp_package_filename[3]='hp-firmware-smartarray-112204add8-2.40-1.1.x86_64.rpm'

    package_description[4]='NC560FLR/Intel        Version  1.7.7        (30 Mar 2015) '
    sp_package_filename[4]='hp-firmware-nic-intel-1.7.7-1.1.x86_64.rpm'

    package_description[5]='Drive firmware        Version         multiple (Apr 2015) '
    sp_package_filename[5]='dskfw/CP*scexe'

    package_description[6]='ILO4                  Version  2015.02.02   (21 Apr 2015) '
    sp_package_filename[6]='hp-firmware-ilo4-2.10-1.1.i386.rpm'

    package_description[7]='HBA/Qlogic/AJ764A     Version  2.10         (30 May 2015) '
    sp_package_filename[7]='hp-firmware-ilo4-2.10-1.1.i386.rpm'

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

  elif [[ "${PRODUCT_NAME}" =~ "DL380p Gen8" || "${PRODUCT_NAME}" =~ "DL380p Gen8" ]]; then

    ######### Preserve this width for screen formatting of description  ###############
    #                      |                                                          |
   
    package_description[1]='DL380p Gen8 BIOS(P70)  Version  2014.08.02 (B)            '
    sp_package_filename[1]='hp-firmware-system-p70-2014.08.02-2.i386.rpm'

    REBOOT_VIA_COLDBOOT="Yes"
    package_description[2]='G8 PowerMgmtCtrl       Version  3.3(C)                    '
    sp_package_filename[2]='hp-firmware-powerpic-gen8-3.3-3.i386.rpm'

    package_description[3]='SmartArray/P822(Critical)Version  6.34       (6 Apr 2015) '
    sp_package_filename[3]='hp-firmware-smartarray-46a4d957a7-6.34-1.1.x86_64.rpm'

    package_description[4]='331FLR/Broadcom        Version  2.14.17     (30 Mar 2015) '
    sp_package_filename[4]='hp-firmware-nic-broadcom-2.14.17-1.1.x86_64.rpm'

    package_description[5]='560FLR/Intel           Version  1.7.7       (30 Mar 2015) '
    sp_package_filename[5]='hp-firmware-nic-intel-1.7.7-1.1.x86_64.rpm'

    package_description[6]='Drive firmware            Version: multiple (Apr 2015)    '
    sp_package_filename[6]='dskfw/CP*scexe'

    package_description[6]='ILO4                   Version: 2015.02.02  (21 Apr 2015) '
    sp_package_filename[6]='hp-firmware-ilo4-2.10-1.1.i386.rpm'

    package_description[7]='HBA/H220 SAS           Version 15.10.07.00                '
    sp_package_filename[7]='CP023362.scexe'
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

  elif [[ "${PRODUCT_NAME}" =~ "Dl385 Gen8" || "${PRODUCT_NAME}" =~ "DL385 Gen8" ]]; then

    ######### Preserve this width for screen formatting of description  ###############
    #                      |                                                          |
   
    package_description[1]='DL385 Gen8 BIOS(A28)   Version: 2014.09.03                '
    sp_package_filename[1]='hp-firmware-system-a28-2014.09.03-2.i386.rpm'

    REBOOT_VIA_COLDBOOT="Yes"
    package_description[2]='G8 PowerMgmtCtrl       Version  3.3(C)                    '
    sp_package_filename[2]='hp-firmware-powerpic-gen8-3.3-3.i386.rpm'

    package_description[3]='SmartArray p420i(Critical)Version: 6.34      (6 Apr 2015) '
    sp_package_filename[3]='hp-firmware-smartarray-46a4d957a7-6.34-1.1.x86_64.rpm'

    package_description[4]='331FLR/Broadcom        Version  2.14.17     (30 Mar 2015) '
    sp_package_filename[4]='hp-firmware-nic-broadcom-2.14.17-1.1.x86_64.rpm'

    package_description[5]='Drive firmware      Version: multiple (Apr 2015)          '
    sp_package_filename[5]='dskfw/CP*scexe'

    package_description[6]='ILO4                   Version: 2015.02.02  (21 Apr 2015) '
    sp_package_filename[6]='hp-firmware-ilo4-2.10-1.1.i386.rpm'

    package_description[7]='HBA/Qlogic/AJ764A     Version  2.10         (30 May 2015) '
    sp_package_filename[7]='hp-firmware-ilo4-2.10-1.1.i386.rpm'

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

  elif [[ "${PRODUCT_NAME}" =~ "BL465c Gen8" || "${PRODUCT_NAME}" =~ "BL465c Gen8" ]]; then

    ######### Preserve this width for screen formatting of description  ###############
    #                      |                                                          |
   
    package_description[1]='BL465 Gen8 BIOS (A26) Version: 2014.11.02                 '
    sp_package_filename[1]='hp-firmware-system-a26-2014.11.02-1.1.i386.rpm'

    REBOOT_VIA_COLDBOOT="Yes"
    package_description[2]='Gen8 PowerMgmtCtrl  Version: 3.3                          '
    sp_package_filename[2]='hp-firmware-powerpic-gen8-3.3-3.i386.rpm'

    package_description[3]='SmartArray p220i(Critical)Version: 6.34      (6 Apr 2015) '
    sp_package_filename[3]='hp-firmware-smartarray-46a4d957a7-6.34-1.1.x86_64.rpm'

    package_description[4]='554FLB/Emulex       Version: 10.2.477.10                  '
    sp_package_filename[4]='hp-firmware-cna-emulex-2015.02.02-1.1.x86_64.rpm'

    package_description[5]='Drive firmware      Version: multiple (Apr 2015)          '
    sp_package_filename[5]='dskfw/CP*scexe'

    package_description[6]='ILO4                Version: 2.10 (May 30 2015)           '
    sp_package_filename[6]='hp-firmware-ilo4-2.10-1.1.i386.rpm'

    package_description[7]='HBA/Emulex/LPe1205A Version 2015.02.01      (30 Mar 2015) '

# BB: A closing quotation mark is missing in the following line. Adding it back in...
    sp_package_filename[7]='hp-firmware-fc-emulex-2015.02.01-1.1.x86_64.rpm'

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

  elif [[ "${PRODUCT_NAME}" =~ "BL660c Gen8" || "${PRODUCT_NAME}" =~ "BL660c Gen8" ]]; then

    ######### Preserve this width for screen formatting of description  ###############
    #                      |                                                          |
   
    package_description[1]='BL660c Gen8 BIOS(I32)  Version: 2014.11.02                '
    sp_package_filename[1]='hp-firmware-system-i32-2014.11.02-1.1.i386.rpm'

    REBOOT_VIA_COLDBOOT="Yes"
    package_description[2]='Gen8 PowerMgmtCtrl  Version: 3.3                          '
    sp_package_filename[2]='hp-firmware-powerpic-gen8-3.3-3.i386.rpm'

    package_description[3]='SmartArray p220i(Critical)Version: 6.34      (6 Apr 2015) '
    sp_package_filename[3]='hp-firmware-smartarray-46a4d957a7-6.34-1.1.x86_64.rpm'

    package_description[4]='560FLR/Intel       Version: 1.7.7           (30 Mar 2015) '
    sp_package_filename[4]='hp-firmware-nic-intel-1.7.7-1.1.x86_64.rpm'

    package_description[5]='Drive firmware     Version: multiple (Apr 2015)           '
    sp_package_filename[5]='dskfw/CP*scexe'

    package_description[6]='ILO4               Version: 2.10 (May 30 2015)            '
    sp_package_filename[6]='hp-firmware-ilo4-2.10-1.1.i386.rpm'

    package_description[7]='HBA/Qlogic/AJ764A     Version  2.10         (30 May 2015) '
    sp_package_filename[7]='hp-firmware-ilo4-2.10-1.1.i386.rpm'


  elif [[ "${PRODUCT_NAME}" =~ "default product" ]]; then

    package_description[1]='No product Match!                                         '
    sp_package_filename[1]='CPxxxxxxx.scexe'

fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 



LAST_CHOICE=${#package_description[@]}
##############################################################################
##############################################################################
##############################################################################
##############################################################################

if [ ! -n "${package_description[1]}" ] ; then
  echo " "
  echo "  Platform did NOT match any defined packages for this product.... "
  echo "   Identified \"PRODUCT_NAME\" = $PRODUCT_NAME   "
  echo "    "
  echo "  exited script with no action."
  echo " Suggest to re-run the script with "ask" parm: # ./firmware_update.sh ask "
  echo "    "
  echo "    "
  echo
  exit
fi

echo ""

echo "Server Type: ${PRODUCT_NAME}"

##################################################################################################
  
echo -e ""
echo -e " Note: During iLO Firmware, remote console maybe lost."
echo -e "       Allow iLO to reset for 2 minutes, then re-connect via browser."
echo -e ""

#  The ETH's must be up for firmware updates 
echo -e " Changing Ethernets to \"up\" state if needed... (must be up for fw updates)"
for eth in `ifconfig -a | grep Ethernet | awk -F" " '{print $1}'`
 do
  export eth
# BB: You don't need to check if the interface is already up.
# BB: ifconfig up won't cause any harm if it's already up
# BB: The back apostrophe is an antique way of command substitution
# BB: use $(...) instead (moot point here, since you don't need the if)
# BB: $(...) stands out much more visually
  if [ `ifconfig $eth | grep -c UP` -eq 0 ] ; then
    echo "   ifconfig $eth up "
    ifconfig $eth up
  fi
done
echo ""

# As a possible work around, allow the script to be executed without PRE-checks
if [[ ! "$PARM" =~ "nopre" ]] ; then

# BB: Since I don't know Emulex FC HBAs, I can't say whether there is a better way
# BB: to implement the section below

  #  I have had problems with the script "hanging" in this section, changed commands to be standalone
  #   writing output to files then reading files.  This allows for an "timeout" use
  #   Very *inefficient* code, but need it to be robust  (kduerr 3/2014)
  #timeout -t 10 ls -l /sys/class/scsi_host/host*/* > /tmp/hba_board_mode

# BB: I would do a simple ls /sys/class/scsi_host/host*
# BB: this generates one line per file in the host* directories
  ls -l /sys/class/scsi_host/host*/* > /tmp/hba_board_mode
# BB: The if condition in the following line will always be true 
# BB: Therefore no need for this if
  if [[ -r /tmp/hba_board_mode ]] ; then
    HBACOUNT=$(grep -c board_mode /tmp/hba_board_mode)    
# BB: since you use [[...]] in other places, why not here? It would be prettier, e.g.
# BB:     if [[ $HBACOUNT > 0 ]]  (no quotation marks, and a greater sign instead of gt)
    if [ "$HBACOUNT" -gt "0" ] ; then
      echo " Changing Emulex FC HBAs to \"offline\" state if possible (board_mode count: $HBACOUNT)"
# BB: Use $(...) instead of `....`
      for hba in `ls /sys/class/scsi_host/host*/board_mode`
        do
        export hba
# BB: The echo below is not needed since the file will be overwritten immediately afterwards
        echo " " > /tmp/hba_online_mode
        timeout -t 2 grep -c online $hba > /tmp/hba_online_mode
# BB: Below: Better: if [[ $(wc -l /tmp/hba_online_mode) == 1 ]]
        if [[ $(cat /tmp/hba_online_mode | wc -l) == 1 ]] ; then
          echo "   offline: $hba "
          echo "offline" > $hba
         else
          echo -n "."
        fi
      done
      echo ""
    fi
    sleep 2
  fi
fi

#======================================================================
#======================================================================
#======================================================================
#======================================================================

while true
do

    # As a possible work around, allow the script to be executed without PRE-checks
    if [[ ! "$PARM" =~ "nopre" ]] ; then
        #######################################################################
        #  Note - this section is a colletion of methods to collect fw/sw data 
        #  
        #   
        #  I have had problems with the script "hanging" in this section, changed commands to be standalone
        #   writing output to files then reading files.  This allows for an "timeout" use
        #   Very *inefficient* code, but need it to be robust  (kduerr 3/2014)
        
        echo -n "  Review: "
        echo -n "( ROM "
        sysbios=`dmidecode 2>/dev/null | grep -i "Release Date:" | awk -F": " '{print $2}'`
        echo -n ")  "
    
        #  Smart Array info
        safwall=""
        echo -n "( SA "
        echo "" > /tmp/hpssacli_show_detail
        export INFOMGR_BYPASS_NONSA=1  #  This is CRTICAL on large system with MANY LUNS, without it hpssacli would appear to "hang"
        if [[ -x /usr/bin/hpssacli ]]; then
          output=`timeout -t 60 /usr/bin/hpssacli ctrl all show detail > /tmp/hpssacli_show_detail`
# BB: I wonder what would happen if hpssacli weren't there or weren't executable? 
# BB: I guess the whole thing would fall apart.
# BB: Point being, there is no need to check if it exists. Just assume it does.
        fi
# BB: Below no need for the quotation marks. And, since you use the "&&" operator, 
# BB: why not ">" instead of "-gt"?
        if [[ -r /tmp/hpssacli_show_detail && "$(grep -ic Slot: /tmp/hpssacli_show_detail)" -gt 0 ]] ; then
          counter=0
          for slot in `grep Slot: /tmp/hpssacli_show_detail | awk -F":" '{print $2}'`
           do
            counter=$(($counter + 1))
            #echo "$counter:slot:$slot"
            saslot[$counter]=$slot
            samodel[$counter]=$(grep "in Slot $slot" /tmp/hpssacli_show_detail | awk -F" in " '{print $1}' | sed -e 's/Smart Array //i')
          done
    
          counter=0
          for safw in `grep "Firmware Version:" /tmp/hpssacli_show_detail | awk -F":" '{print $2}'`
           do
            counter=$(($counter + 1))
            #echo "$counter:safw:$safw"
            sasafw[$counter]=$safw
            echo -n "^"
          done
        fi
        if [[ $counter -gt 0 ]] ; then
          for (( slot=1; slot<=$counter; slot++ )) 
            do
              safwall="$safwall${samodel[$slot]}:Slot${saslot[$slot]}:${sasafw[$slot]} "
          done
        fi
        echo -n ")   "
    
        # Disc drive
        drivefwall=""
        drivefwall2=""
        sumdrivefw_total_count=0
        echo "" > /tmp/hpssacli_show_config_detail
        export INFOMGR_BYPASS_NONSA=1  #  This is CRTICAL on large system with MANY LUNS, without it hpssacli would appear to "hang"
        if [[ -x /usr/bin/hpssacli ]]; then
          output=`timeout -t 60 /usr/bin/hpssacli ctrl all show config detail > /tmp/hpssacli_show_config_detail`
         else
          output=`timeout -t 60 hpssacli ctrl all show config detail > /tmp/hpssacli_show_config_detail`
        fi
        if [[ -r /tmp/hpssacli_show_config_detail && "$(grep -ic "Model: HP" /tmp/hpssacli_show_config_detail)" -gt 0 ]] ; then
          counter=0
          for drive in `grep -i "Model: HP" /tmp/hpssacli_show_config_detail | awk -F" " '{print $3}'`
           do
            counter=$(($counter + 1))
            drivemodel[$counter]=$drive
          done
    
          counter=0
          for fw in `grep "Firmware Revision:" /tmp/hpssacli_show_config_detail | awk -F":" '{print $2}'`
           do
            counter=$(($counter + 1))
            drivefw[$counter]=$fw        
          done
        fi
        if [[ $counter -gt 0 ]] ; then
          for (( drive=1; drive<=$counter; drive++ ))
            do
              drivefwall="$drivefwall ${drivemodel[$drive]}:${drivefw[$drive]} "
          done
          
          #  Create differnt summay...  model/fw count
          grep -i "Model: HP" /tmp/hpssacli_show_config_detail | awk -F" " '{print $3}' | sort -u > /tmp/hpssacli_hdd_models.txt
          for hdd_model in `cat /tmp/hpssacli_hdd_models.txt`
            do
              awk -v patt="$hdd_model" '$0 ~ patt {for(i=0; i<=5; i++) {print s[NR-i]}} {s[NR]=$0}' /tmp/hpssacli_show_config_detail | grep "Firmware Revision:" | awk -F": " '{print $2}' | sort -u > /tmp/hddfw-$hdd_model.txt
              drivefwall2="$drivefwall2$hdd_model ("
              for hddfw in `cat /tmp/hddfw-$hdd_model.txt`
              do
                drivefwcount=$(awk -v patt="$hdd_model" '$0 ~ patt {for(i=0; i<=5; i++) {print s[NR-i]}} {s[NR]=$0}' /tmp/hpssacli_show_config_detail | grep "Firmware Revision" | awk -F": " '{print $2}' | grep -ic $hddfw)
                drivefwall2="$drivefwall2$hddfw=$drivefwcount "
              done
              drivefwall2="$drivefwall2)  "
          done
        fi
    
    
        #  SAS info
        sasfwall=""
        awk '/SAS Exp Card/ {for(i=1; i<=5; i++) {getline; print}}' /tmp/hpssacli_show_config_detail | grep "Firmware Version" | awk -F": " '{print $2}' | sort -u > /tmp/sas_info.txt
        for fw in `cat /tmp/sas_info.txt`
        do
          sasfwall="$sasfwall$fw; "
        done
    
        
        if [ ! $TESTING_ONLY ] ; then
          # Get iLO firmware level
          echo -n "( iLO "
          if [[ -x /bin/hponcfg ]]; then
            ilofw=`/bin/hponcfg -h | grep Firmware | awk -F" " '{print $4}'`
          fi
          echo -n ")   "
        fi
        
        ethfwall=""
        if [[ -r /tmp/ethXfw.txt ]] ; then
          rm /tmp/ethXfw.txt
        fi
        echo -n "( eth "
        for eth in `ifconfig -a 2>/dev/null | grep Ethernet | awk -F" " '{print $1}'`
        do
          export eth
          echo -n "^"
          ethtool -i $eth | grep -i firmware | awk -F": " '{print $2}' | sed -e 's/,//g' -e 's/ /_/g' >> /tmp/ethXfw.txt
        done
        sort -u /tmp/ethXfw.txt > /tmp/ethXfw-uniq.txt
        for ethfw in `cat /tmp/ethXfw-uniq.txt`
         do
          fwcount=`grep -ic $ethfw /tmp/ethXfw.txt`
          ethfwall="$ethfwall$ethfw:Qty=$fwcount "
        done
        echo -n ")   "
    
        hbafwall=""
        echo -n "( hba "
        if [ -d /sys/class/scsi_host/host0 ] ; then
          for hba in `ls -d /sys/class/scsi_host/host*`
           do
            export hba
            export hostnum=`echo $hba | cut -d'/' -f5`
            #  Emulex
            if [ -r $hba/fwrev ] ; then
              echo -n "^"
              hbafw=`awk -F" " '{print $1}' $hba/fwrev`
              hbamodel=`awk -F" " '{print $1}' $hba/modelname`
              hbafwall="$hbafwall $hostnum:$hbamodel:$hbafw "
            fi            
            # Qlogic
            if [ -r $hba/optrom_fw_version ] ; then
              echo -n "^"
              hbafw=`awk -F" " '{print $1}' $hba/optrom_fw_version`
              hbamodel=`awk -F" " '{print $1}' $hba/model_name`
              hbafwall="$hbafwall $hostnum:$hbamodel:$hbafw "
            fi
          done
        fi
        echo -n ") "
    
        if [ -n "$STOPWATCH" ] ; then
          # The stop watch has a value, show it
          echo
          echo "  Component Update Time measurements: "
          echo "   $STOPWATCH";
        fi
         
        echo " "
        echo " "
        echo " ======  Firmware Current Versions:  ========================================"
        echo " ${PRODUCT_NAME}        BIOS = $sysbios     iLO = $ilofw  "
        echo " Serial_ID: $SERIAL_ID   SmartArray: $safwall  SAS Exp FW: $sasfwall"
        if [[ ! "$drivefwall2" == "" ]] ; then
          echo " HDD-FW: $drivefwall2"  
         else
          if [[ ! "$drivefwall" == "" ]] ; then
            echo " HDD-FW: $drivefwall"   
          fi    
        fi
        echo " Eth-FW:$ethfwall"
        if [[ ! "$hbafwall" == "" ]] ; then
          echo " HBA-FW:$hbafwall"
        fi
        echo " ============================================================================"
        echo " "

    fi
    
    
    #######################################################################
    #  Note - this section happens when the comming to the top of the loop 2nd+ times
    #  If in "AUTO" mode, want to display the firmware before the reboot....at least for a few secs
    if [[ "$MODE" =~ "AUTO_WITH_REBOOT" ]] ; then
      #  reboot
      if [[ "$REBOOT_VIA_COLDBOOT" =~ "Yes" ]] ; then
        # We are going to reboot via an iLO cold boot....
        #  There is a chance the iLO was updated, need to allow 3 minutes for it to be fully rebooted
        echo -e ""
        echo -e " Rebooting system via iLO COLDBOOT.... (in 180 secs - allow iLO to be reset)"
        echo -e ""
        sleep 180
        echo "<RIBCL VERSION=\"2.0\"><LOGIN USER_LOGIN=\"na\" PASSWORD=\"na\"><SERVER_INFO MODE=\"write\"><COLD_BOOT_SERVER/></SERVER_INFO></LOGIN></RIBCL>" > iLO_Coldboot.xml
        echo "Running hponcfg with COLDBOOT XML file... see ya!"
        /bin/hponcfg -f iLO_Coldboot.xml
       else
        echo -e ""
        echo -e " Rebooting system.... (in 15 secs)"
        echo -e ""
        sleep 15
        reboot
      fi
      echo -e " Script is exiting....  (normal exit)."
      exit
    fi
      

    echo " Select: UPDATE CHOICES _____________________________________ISOver:${VERSION}___"
    echo " "
    ALLCHOICES=""
    for (( CHOICES=1; CHOICES<=$LAST_CHOICE; CHOICES++ ))
    do 
        echo "  $CHOICES) ${package_description[$CHOICES]} ${sp_package_filename[$CHOICES]:0:14} ${package_tracker[$CHOICES]}"
        ALLCHOICES="$ALLCHOICES $CHOICES"
    done
    
    echo
    echo "     a) all of the above              A) all of the above WITH REBOOT"
    echo "     q) Quit script                   m) Manual mode (stop timmer) "
  
    echo
    if [ -n "$MODE" -o -n "$CHOICE" ] ; then
      # non-NULL check, Some selections have been made before...  to not do a timer
      read -p " Please enter your choice. " CHOICE
      echo -e ""
     else
      read -p " Please enter your choice. [ default selection is choice \"A\" in 60 secs ] " -t60 CHOICE
      echo -e " "
      if [ "$CHOICE" = "" ] ; then
        # Last chance
        echo "    #################################################################"
        echo "    #################################################################"
        echo "    #################################################################"
        echo "    ##########                                          #############"
        echo "    ##########        S  T  A  R  T  I  N  G            #############"
        echo "    ##########                                          #############"
        echo "    ##########           U  P  D  A  T  E               #############"
        echo "    ##########                                          #############"
        echo "    ##########          !!!   N  O  W   !!!             #############"
        echo "    ##########                                          #############"
        echo "    #################################################################"
        echo "    #################################################################"
        echo "    #################################################################"
        echo " "
        read -p " enter q, then press enter to quit  (within 30 secs) last chance... " -t30 CHOICE
        echo -e "  "
        if [ "$CHOICE" = "" ] ; then
          CHOICE="A"
        fi
      fi
    fi
    if [ "$CHOICE" = "q" -o "$CHOICE" = "Q" ] ; then
      echo -e ""
      echo -e ""
      echo -e " Exiting utility, returning to a shell. "
      echo -e ""
      echo -e "  to restart script, run ./myfirmware_update.sh"
      echo -e ""
      echo -e " To reboot, type reboot or press virtual power buttons. "
      echo -e "  Note: to ACTIVATE some firmware, "
      echo -e "        1) Unmount media "
      echo -e "        2) Perfrom a COLD BOOT via virtual power buttons"
      echo -e ""
      exit
    fi
    if [ "$CHOICE" = "m" -o "$CHOICE" = "M" ] ; then
      MODE="MANUAL"
      echo " changed to manual mode.... (no auto timer) "
      echo
      CHOICE=""
    fi
    if [ "$CHOICE" = "a" ] ; then
      MODE="AUTO"
      CHOICE=$ALLCHOICES
    fi
    if [ "$CHOICE" = "A" ] ; then
      MODE="AUTO_WITH_REBOOT"
      CHOICE=$ALLCHOICES
    fi

    #  Do we need to "expode" a disk drive firmware choice?
    #  example: sp_package_filename[8]='dskfw/CP*scexe'
    DRIVEMODELS=${#drivemodel[@]}
    counter=0
    trackinglist=" "
    REVIEWEDCHOICE=""
    PREDESCRIPTION="  Adding sub choices for Menu item #$ITEM (found matching harddrive firmware)\n\n"
    for ITEM in $CHOICE
     do
      if [[ ${sp_package_filename[ITEM]} =~ "dskfw/CP*scexe" ]] ; then
        # Yes!
        if [[ $DRIVEMODELS -gt 0 ]] ; then
          for CP in `ls /TOOLKIT/dskfw/CP*scexe`
           do
            CPbasename=$(basename $CP)
            chmod 777 $CP
            $CP --unpack=/tmp/$CPbasename/ > /dev/null 2>&1
            for (( model=1; model<=$DRIVEMODELS; model++ ))
             do
              if [[ $(echo $trackinglist | grep -c ${drivemodel[$model]}) -eq 0 ]] ; then
                if [[ $(grep -ic ${drivemodel[$model]} /tmp/$CPbasename/CP*.xml) -gt 0 ]] ; then
                  counter=$(($counter + 1))
                  NEWITEM=$((ITEM * 100 + $counter))
                  package_description[$NEWITEM]="HDD firmware - model: ${drivemodel[$model]}"
                  sp_package_filename[$NEWITEM]="dskfw/$CPbasename"                
                  REVIEWEDCHOICE="$REVIEWEDCHOICE $NEWITEM"
                  trackinglist="$trackinglist ${drivemodel[$model]}"
                  echo -e "$PREDESCRIPTION   Added $counter (Ref:$NEWITEM) HDD Fw Model:${drivemodel[$model]} / $CPbasename"
                  PREDESCRIPTION=""
                fi
              fi
            done
          done
         else
          echo " Item $ITEM excluded - no HP drive models determined from hp sa/acu cli.... "
        fi
       else
        REVIEWEDCHOICE="$REVIEWEDCHOICE $ITEM"
      fi
    done
    CHOICE=$REVIEWEDCHOICE    
    
    echo -e " "
    echo -e " "
    echo -e " "
    
    echo -e " Initiating UPDATES - do not disrupt from this point on until done. "
    echo "      ( Choice = $CHOICE   Mode = $MODE ) "
    echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    echo " "
    sleep 3
    
    #######################################################################
    for ITEM in $CHOICE
    do
      if [[ "$ITEM" -ge "0"  ]] ; then
      #if [[ ( "$ITEM" -ge "1" &&  "$ITEM" -le "$LAST_CHOICE" ) || "$ITEM" = "a" || "$ITEM" = "A" ]] ; then
  
        echo " # $ITEM: Updating ${package_description[$ITEM]}"
        package_tracker[$ITEM]="X"
                
        # If iLO show addtional text
        if [[ ${package_description[$ITEM]} =~ "ilo"  ]] ; then
          echo -e ""
          echo -e " Note:  Remote console maybe lost during this update..."
          echo -e ""
        fi
        
        if [ -e ${TOOLKIT}/${sp_package_filename[$ITEM]} ] ; then
          chmod +x ${TOOLKIT}/${sp_package_filename[$ITEM]}
         else
          echo " MAJOR PROBLEMS - the file ${sp_package_filename[$ITEM]} does NOT exist!!!  can not execute it! "
          echo " exiting script... "
          echo " "
          exit
        fi
  
        STARTTIME=$SECONDS
        if [ $TESTING_ONLY ] ; then
          echo -n "  testing ONLY - no execution..... "
          sleep 5
         else
         
          apply_count=1
          if [[ -n ${package_apply_count[$ITEM]} ]] ; then
            if [ ${package_apply_count[$ITEM]} -gt "1" ] ; then
              apply_count=${package_apply_count[$ITEM]}
             else
              apply_count=1
            fi
           else
            apply_count=1
          fi
          
          #  Depends on if CP or .RPM
          if [[ "${sp_package_filename[$ITEM]}" =~ "scexe" ]] ; then
            # CP package - set the full path to the package
            export this_sp_package_filename="${TOOLKIT}/${sp_package_filename[$ITEM]}"
          fi
          if [[ "${sp_package_filename[$ITEM]}" =~ "rpm" ]] ; then
            # This is an RPM, we need to take a couple steps...
            # unpack it - with the STK, we cannot do an rpm -install
            echo " executing rpm2cpio (extract content and get file name...) "
            `cd / ; rpm2cpio ${TOOLKIT}/${sp_package_filename[$ITEM]} | cpio -idm > /dev/null 2>&1`
            # determine the embeded CP package name
            export this_sp_package_filename=$(cd / ; rpm2cpio ${TOOLKIT}/${sp_package_filename[$ITEM]} | cpio -t | grep CP.*scexe | head -1)
          fi
          
          echo "   executing:  $this_sp_package_filename -s "
          for l in {1..$apply_count}
          do
            cpoutput=$(cd / ; $this_sp_package_filename -s  2>&1 )
            cpexitcode=$?
          done
          
          case $cpexitcode in
           0|1) 
            echo -n "  - updated  [exitcode: $cpexitcode] "
            echo " ${sp_package_filename[$ITEM]} [$cpoutput] " >> /tmp/executed_cp.txt
            ;;
           2|3)  
            echo -e "  - is already up to date, or no update needed [exitcode: $cpexitcode]"
            echo " ${sp_package_filename[$ITEM]} [$cpoutput] " >> /tmp/executed_cp.txt
          
            # If iLO and AUTO mode, take additonal action
            if [[ $( echo ${package_description[$ITEM]} | grep -ic "ilo") -ne 0 &&  "$MODE" = "AUTO_WITH_REBOOT"  ]] ; then
              echo "Running in AUTO MODE, and ILO did not need to be updated, script is reseting iLO to disconect media for reboot in 5 secs..."
              echo " "
              sleep 5
              echo "<RIBCL VERSION=\"2.0\"><LOGIN USER_LOGIN=\"na\" PASSWORD=\"na\"><RIB_INFO MODE=\"write\"><RESET_RIB/></RIB_INFO></LOGIN></RIBCL>" > iLO_Reset.xml
              echo "Running hponcfg with reset XML file..."
              /bin/hponcfg -f iLO_Reset.xml
              echo " Reset command issued! "
              sleep 3
            fi
            ;;
           127) 
            echo -n "  - ERROR with update command  [exitcode: $cpexitcode] "
            echo " ${sp_package_filename[$ITEM]} [$cpoutput] ERROR " >> /tmp/executed_cp.txt
            sleep 10
            ;;
           252|253|254|255) 
            echo -n "  - FAILURE with update command  [exitcode: $cpexitcode] "
            echo " ${sp_package_filename[$ITEM]} [$cpoutput] ERROR " >> /tmp/executed_cp.txt
            sleep 10
            ;;
           *) 
            echo -n "  - update command completed - unexpeted return code [exitcode: $cpexitcode] "
            echo " ${sp_package_filename[$ITEM]} [$cpoutput] ERROR " >> /tmp/executed_cp.txt
            sleep 5
            ;;
          esac

        fi
        ENDTIME=$SECONDS
        package_time[$ITEM]=$(($ENDTIME - $STARTTIME))
        echo -e "     (Time to complete selection #$ITEM: ${package_time[$ITEM]} secs)"

      fi
      echo " "
      echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
      echo " "
      
      sleep 5

    done
    
    
    TOTALTIME="0"
    for ITEM in $CHOICE
    do 
      if [ -n "${package_time[$ITEM]}" ] ; then
        TOTALTIME=$(( $TOTALTIME + ${package_time[$ITEM]}))
      fi
    done
    STOPWATCH="Stop Watch: Total time=$TOTALTIME secs ["
    for ITEM in $CHOICE
    do 
      if [ -n "${package_time[$ITEM]}" ] ; then
        STOPWATCH="$STOPWATCH #$ITEM=${package_time[$ITEM]}s"
      fi
    done
    STOPWATCH="$STOPWATCH ]"
    
  
    #######################################################################
    echo
    if [[ "$MODE" == "AUTO" ]] ; then
      # This is AUTO mode, not AUTO_WITH_REBOOT
      # Save screen data
      echo
      echo "  Component Update Time measurements: "
      echo "   $STOPWATCH";
      echo
      read -p " Please enter to continue... " CHOICE
      echo
      CHOICE=""
      MODE="MANUAL"
    fi 
    echo
    echo
  
  #  Forever L - O - O - P ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
done
  
