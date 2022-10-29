#!/bin/bash

# COLOR FORE
RED='\e[91m'
BLUE='\e[94m'
YELLOW='\e[93m'
GREEN='\e[92m'
NC='\e[39m'

CONFORMITY="0"

function level_low() {
    local BOOT_PARTITION="$(lsblk | sed -En '/.*?part\s*\/boot/p')"
    if [[ -z ${BOOT_PARTITION} ]]; then
        echo -e "${RED}[!]${NC} /boot not in the separate partition"
    else
        echo -e "${GREEN}[+]${NC} /boot in the separate file"
        CONFORMITY="$(expr ${CONFORMITY}+1)"
    fi

    local HOME_PARTITION="$(lsblk | sed -En '/.*?part\s*\/home/p')"
    if [[ -z ${HOME_PARTITION} ]]; then
        echo -e "${RED}[!]${NC} /home not in the separate partition"
    else
        echo -e "${GREEN}[+]${NC} /home in the separate file"
        CONFORMITY="$(expr ${CONFORMITY}+1)"
    fi

    local USR_PARTITION="$(lsblk | sed -En '/.*?part\s*\/usr/p')"
    if [[ -z ${USR_PARTITION} ]]; then
        echo -e "${RED}[!]${NC} /usr not in the separate partition"
    else
        echo -e "${GREEN}[+]${NC} /usr in the separate file"
        CONFORMITY="$(expr ${CONFORMITY}+1)"
    fi

    RESTRICT_USR="$(sed -En '/^\s*UUID.*?\/usr/p' /etc/fstab | awk -F' ' '{print $4}')"
    if [[ -z ${RESTRICT_USR} ]]; then
        echo -e "${RED}[!]${NC} /usr not restricted"
    else
        RESTRICT_USR_NUMBER="$(echo ${RESTRICT_USR} | sed 's/,/\n/g' | wc -l)"
        for i in $(seq 1 ${RESTRICT_USR_NUMBER}); do
            RESTRICT_USR_ARG_CURRENT="$(echo ${RESTRICT_USR} | sed 's/,/\n/g' | sed -n ${i}p)"
            if [[ ${RESTRICT_USR_ARG_CURRENT} == "defaults" ]]; then
                RESTRICT_USR_ARG_DEFAULTS="1"
            elif [[ ${RESTRICT_USR_ARG_CURRENT} == "nodev" ]]; then
                RESTRICT_USR_ARG_NODEV="1"
            elif [[ ${RESTRICT_USR_ARG_CURRENT} == "ro" ]]; then
                RESTRICT_USR_ARG_RO="1"
            fi
        done

        if [[ ${RESTRICT_USR_ARG_DEFAULTS} == "1" && ${RESTRICT_USR_ARG_NODEV} == "1" && ${RESTRICT_USR_ARG_RO} == "1" ]]; then
            echo -e "${GREEN}[+]${NC} /usr correctly restricted"
            CONFORMITY="$(expr ${CONFORMITY}+1)"
        else
            echo -e "${RED}/usr${NC}"
            if [[ ${RESTRICT_USR_ARG_DEFAULTS} != "1" ]]; then
                echo -e "  ➥ ${RED}default${NC} missing"
            fi
            
            if [[ ${RESTRICT_USR_ARG_NODEV} != "1" ]]; then
                echo -e "  ➥ ${RED}nodev${NC} missing"
            fi
            
            if [[ ${RESTRICT_USR_ARG_RO} != "1" ]]; then
                echo -e "  ➥ ${RED}ro${NC} missing"
            fi
        fi
    fi

    RESTRICT_VAR="$(sed -En '/^\s*UUID.*?\/var/p' /etc/fstab | awk -F' ' '{print $4}')"
    if [[ -z ${RESTRICT_VAR} ]]; then
        echo -e "${RED}[!]${NC} /var not restricted"
    else
        RESTRICT_VAR_NUMBER="$(echo ${RESTRICT_VAR} | sed 's/,/\n/g' | wc -l)"
        for i in $(seq 1 ${RESTRICT_VAR_NUMBER}); do
            RESTRICT_VAR_ARG_CURRENT="$(echo ${RESTRICT_VAR} | sed 's/,/\n/g' | sed -n ${i}p)"
            if [[ ${RESTRICT_VAR_ARG_CURRENT} == "defaults" ]]; then
                RESTRICT_VAR_ARG_DEFAULTS="1"
            elif [[ ${RESTRICT_VAR_ARG_CURRENT} == "nosuid" ]]; then
                RESTRICT_VAR_ARG_NOSUID="1"
            fi
        done

        if [[ ${RESTRICT_VAR_ARG_DEFAULTS} == "1" && ${RESTRICT_VAR_ARG_NOSUID} == "1" ]]; then
            echo -e "${GREEN}[+]${NC} /var correctly restricted"
            CONFORMITY="$(expr ${CONFORMITY}+1)"
        else
            echo -e "${RED}/var${NC}"
            if [[ ${RESTRICT_VAR_ARG_DEFAULTS} != "1" ]]; then
                echo -e "  ➥ ${RED}default${NC} missing"
            fi
            
            if [[ ${RESTRICT_VAR_ARG_NOSUID} != "1" ]]; then
                echo -e "  ➥ ${RED}nosuid${NC} missing"
            fi
        fi
    fi

    RESTRICT_VAR_LOG="$(sed -En '/^\s*UUID.*?\/var\/log /p' /etc/fstab | awk -F' ' '{print $4}')"
    if [[ -z ${RESTRICT_VAR_LOG} ]]; then
        echo -e "${RED}[!]${NC} /var/log not restricted"
    else
        RESTRICT_VAR_LOG_NUMBER="$(echo ${RESTRICT_VAR_LOG} | sed 's/,/\n/g' | wc -l)"
        for i in $(seq 1 ${RESTRICT_VAR_LOG_NUMBER}); do
            RESTRICT_VAR_LOG_ARG_CURRENT="$(echo ${RESTRICT_VAR_LOG} | sed 's/,/\n/g' | sed -n ${i}p)"
            if [[ ${RESTRICT_VAR_LOG_ARG_CURRENT} == "defaults" ]]; then
                RESTRICT_VAR_LOG_ARG_DEFAULTS="1"
            elif [[ ${RESTRICT_VAR_LOG_ARG_CURRENT} == "nosuid" ]]; then
                RESTRICT_VAR_LOG_ARG_NOSUID="1"
            elif [[ ${RESTRICT_VAR_LOG_ARG_CURRENT} == "noexec" ]]; then
                RESTRICT_VAR_LOG_ARG_NOEXEC="1"
            elif [[ ${RESTRICT_VAR_LOG_ARG_CURRENT} == "nodev" ]]; then
                RESTRICT_VAR_LOG_ARG_NODEV="1"
            fi
        done

        if [[ ${RESTRICT_VAR_LOG_ARG_DEFAULTS} == "1" && ${RESTRICT_VAR_LOG_ARG_NOSUID} == "1" && ${RESTRICT_VAR_LOG_ARG_NOEXEC} == "1" && ${RESTRICT_VAR_LOG_ARG_NODEV} == "1" ]]; then
            echo -e "${GREEN}[+]${NC} /var/log correctly restricted"
            CONFORMITY="$(expr ${CONFORMITY}+1)"
        else
            echo -e "${RED}/var/log${NC}"
            if [[ ${RESTRICT_VAR_LOG_ARG_DEFAULTS} != "1" ]]; then
                echo -e "  ➥ ${RED}default${NC} missing"
            fi
            
            if [[ ${RESTRICT_VAR_LOG_ARG_NOSUID} != "1" ]]; then
                echo -e "  ➥ ${RED}nosuid${NC} missing"
            fi
            
            if [[ ${RESTRICT_VAR_LOG_ARG_NOEXEC} != "1" ]]; then
                echo -e "  ➥ ${RED}noexec${NC} missing"
            fi

            if [[ ${RESTRICT_VAR_LOG_ARG_NODEV} != "1" ]]; then
                echo -e "  ➥ ${RED}nodev${NC} missing"
            fi
        fi
    fi

    RESTRICT_VAR_LOG_AUDIT="$(sed -En '/^\s*UUID.*?\/var\/log\/audit /p' /etc/fstab | awk -F' ' '{print $4}')"
    if [[ -z ${RESTRICT_VAR_LOG_AUDIT} ]]; then
        echo -e "${RED}[!]${NC} /var/log/audit not restricted"
    else
        RESTRICT_VAR_LOG_AUDIT_NUMBER="$(echo ${RESTRICT_VAR_LOG_AUDIT} | sed 's/,/\n/g' | wc -l)"
        for i in $(seq 1 ${RESTRICT_VAR_LOG_AUDIT_NUMBER}); do
            RESTRICT_VAR_LOG_AUDIT_ARG_CURRENT="$(echo ${RESTRICT_VAR_LOG_AUDIT} | sed 's/,/\n/g' | sed -n ${i}p)"
            if [[ ${RESTRICT_VAR_LOG_AUDIT_ARG_CURRENT} == "defaults" ]]; then
                RESTRICT_VAR_LOG_AUDIT_ARG_DEFAULTS="1"
            elif [[ ${RESTRICT_VAR_LOG_AUDIT_ARG_CURRENT} == "nosuid" ]]; then
                RESTRICT_VAR_LOG_AUDIT_ARG_NOSUID="1"
            elif [[ ${RESTRICT_VAR_LOG_AUDIT_ARG_CURRENT} == "noexec" ]]; then
                RESTRICT_VAR_LOG_AUDIT_ARG_NOEXEC="1"
            elif [[ ${RESTRICT_VAR_LOG_AUDIT_ARG_CURRENT} == "nodev" ]]; then
                RESTRICT_VAR_LOG_AUDIT_ARG_NODEV="1"
            fi
        done

        if [[ ${RESTRICT_VAR_LOG_AUDIT_ARG_DEFAULTS} == "1" && ${RESTRICT_VAR_LOG_AUDIT_ARG_NOSUID} == "1" && ${RESTRICT_VAR_LOG_AUDIT_ARG_NOEXEC} == "1" && ${RESTRICT_VAR_LOG_AUDIT_ARG_NODEV} == "1" ]]; then
            echo -e "${GREEN}[+]${NC} /var/log/audit correctly restricted"
            CONFORMITY="$(expr ${CONFORMITY}+1)"
        else
            echo -e "${RED}/var/log/audit${NC}"
            if [[ ${RESTRICT_VAR_LOG_AUDIT_ARG_DEFAULTS} != "1" ]]; then
                echo -e "  ➥ ${RED}default${NC} missing"
            fi
            
            if [[ ${RESTRICT_VAR_LOG_AUDIT_ARG_NOSUID} != "1" ]]; then
                echo -e "  ➥ ${RED}nosuid${NC} missing"
            fi
            
            if [[ ${RESTRICT_VAR_LOG_AUDIT_ARG_NOEXEC} != "1" ]]; then
                echo -e "  ➥ ${RED}noexec${NC} missing"
            fi

            if [[ ${RESTRICT_VAR_LOG_AUDIT_ARG_NODEV} != "1" ]]; then
                echo -e "  ➥ ${RED}nodev${NC} missing"
            fi
        fi
    fi
}

function main() {
    clear
    echo -e "LINUX HARDENING"
    echo -e "Based on : https://github.com/trimstray/linux-hardening-checklist"

    if [[ ${LEVEL_SELECTED} == "default" ]]; then
        level_low

    elif [[ ${LEVEL_SELECTED} == "low" ]]; then
        level_low

        if [[ ${CONFORMITY} > "10" ]];then
            echo -e "Conformity level : ${GREEN}${CONFORMITY}${NC}/20"
        fi
    fi

}

while [ $# -gt 0 ]; do
    case $1 in
        -l|--level)
            LEVEL_SELECTED="${2}"
            if [[ -z ${LEVEL_SELECTED} ]]; then
                LEVEL_SELECTED="default"
            fi
            ;;
        -h|--help)
            ;;
    esac
    shift
done

main
