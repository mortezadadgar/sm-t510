#!/bin/bash

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

START=$(date +%s)

export ARCH=arm64
export CROSS_COMPILE=../../gcc_4.9/bin/aarch64-linux-android-
export ANDROID_MAJOR_VERSION=p

echo -e "\e[1;36m choose between stock or GSI defconfig: \e[0m"
printf "\n1.STOCK\n"
printf "2.GSI\n\n"
read -p "Choice:" defconfig
clear
if [ $defconfig = 1 ] ;then
	echo -e "\e[1;31m Building for STOCK \e[0m"
	make exynos7885-gta3xlwifi_defconfig
elif [ $defconfig = 2 ] ;then
	echo -e "\e[1;31m Building for GSI \e[0m"
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
make -j$(nproc --all)

END=$(date +%s)
echo "Compilation time:${RST} $(format_time "${START}" "${END}")"


