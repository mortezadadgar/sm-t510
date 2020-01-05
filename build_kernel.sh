#!/bin/bash

### FUNCTIONS ###
# Formats the time for the end
function format_time() {
    MINS=$(((${2} - ${1}) / 60))
    SECS=$(((${2} - ${1}) % 60))
    if [[ ${MINS} -ge 60 ]]; then
        HOURS=$((MINS / 60))
        MINS=$((MINS % 60))
    fi

    if [[ ${HOURS} -eq 1 ]]; then
        TIME_STRING+="1 HOUR, "
    elif [[ ${HOURS} -ge 2 ]]; then
        TIME_STRING+="${HOURS} HOURS, "
    fi

    if [[ ${MINS} -eq 1 ]]; then
        TIME_STRING+="1 MINUTE"
    else
        TIME_STRING+="${MINS} MINUTES"
    fi

    if [[ ${SECS} -eq 1 && -n ${HOURS} ]]; then
        TIME_STRING+=", AND 1 SECOND"
    elif [[ ${SECS} -eq 1 && -z ${HOURS} ]]; then
        TIME_STRING+=" AND 1 SECOND"
    elif [[ ${SECS} -ne 1 && -n ${HOURS} ]]; then
        TIME_STRING+=", AND ${SECS} SECONDS"
    elif [[ ${SECS} -ne 1 && -z ${HOURS} ]]; then
        TIME_STRING+=" AND ${SECS} SECONDS"
    fi

    echo "${TIME_STRING}"
}

# copy boot image and place it in anykernel directory
anykernel()
{
	while true
	do
		read -p "Please enter anykernel path : " anykernel
		cp arch/arm64/boot/Image $anykernel
		cd $anykernel && return
		sleep 5s
	done
}

START=$(date +%s)

### COMPILATION ###
#exporting building variables
export ARCH=arm64
echo -e "\e[1;36m CROSS_COMPILE path should be like this : \e[0m"
printf "\n../gcc_version/bin/aarch64-linux-android-\n\n"
read -p "Please enter CROSS_COMPILE path : " cross_compile
export CROSS_COMPILE=$cross_compile
export ANDROID_MAJOR_VERSION=p
clear

#cleaning
echo "do you want to clean the kernel source?"
read -p "(y/n)" clean
if [ $clean = "y" ] ;then
	echo -e "\e[1;31m Cleaning kernel source \e[0m"
	sleep 5s
	make clean && make mrproper
else
	echo -e "\e[1;31m Not cleaning kernel source \e[0m"
	sleep 5s
fi
clear

#building
echo -e "\e[1;36m choose between stock or GSI defconfig: \e[0m"
printf "\n1.STOCK\n"
printf "2.GSI\n\n"
read -p "Choice:" defconfig
clear
if [ $defconfig = 1 ] ;then
	echo -e "\e[1;31m Building for STOCK \e[0m"
	sleep 5s
	make exynos7885-gta3xlwifi_defconfig
elif [ $defconfig = 2 ] ;then
	echo -e "\e[1;31m Building for GSI \e[0m"
	sleep 5s
	make exynos7885-gta3xlwifi_gsi_defconfig
else
	echo bad option, please run script again
	exit
fi
clear
echo -e "\e[1;31m starting build \e[0m"
sleep 5s
clear
echo -e "\e[1;31m BUILD SETUP : \e[0m"
echo "ARCHITECTURE : $ARCH"
echo "ANDROID VERSION : $ANDROID_MAJOR_VERSION"
echo "TOOLCHAIN : $CROSS_COMPILE"
sleep 10s
printf "\nBuilding...\n"
make -j$(nproc --all) || exit 1
echo -e "\e[1;31m BUILD DONE! \e[0m"
END=$(date +%s)
echo "Compilation time:${RST} $(format_time "${START}" "${END}")"

#build kernel zip
echo "Do you want a kernel zip?"
read -p "(y/n)" kernel_zip
if [ $kernel_zip = "y" ] ;then
	echo -e "\e[1;31m Building kernel zip \e[0m"
	anykernel
	read -p "Please enter zip name : " zipname
	zip -r $zipname.zip *
else
	echo -e "\e[1;31m Not building kernel zip \e[0m"
fi
