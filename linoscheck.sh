#!/bin/bash

#Prints All The Gathered Specifications 
print_info() {
    echo "$1"
}

########Function To Make Sure Script Is Run by Root#######
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "This script must be run as root."
        exit 1
    fi
}
#Runs The check_root Function
check_root

#########################################################
########################FLAGS############################
# Initialize Flags For Proxmox
#qemu_found=false

# Initialize Flags For VMWare
vmware_dmesg_found=false

#Initialize Flags for Azure HCI and Azure Cloud
azurehci_assettag_found=false
azurehci_demesg_found=false

#Initialize Flags for Azure Cloud
azurecloud_assettag_found=false

#Initialize Flags For Oracle Cloud 
oraclecloud_assettag_found=false

#Initialize Flags For KVM 
kvm_found=false 
#########################################################
##########Check If The System Is Virtualized#############
if hostnamectl | grep -i vm >/dev/null; then
    print_info "Virtualization: Yes"
else
    print_info "Virtualization: No"
    print_info "Virtualization Client: None (Bare Metal)"
    # Output distribution and kernel version before exiting
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        print_info "Linux Distribution: $NAME"
        print_info "Version: $VERSION"
    else
        print_info "Distribution information not found."
    fi
    print_info "Kernel Version: $(uname -r)"
    exit 0
fi
#########################################################
####################FLAG TRIGGERS########################


# Check for QEMU In The System Manufacturer (dmidecode)
#if dmidecode -s system-manufacturer | grep -i 'qemu'; then
#   qemu_found=true
#fi

# Check 'dmesg' For VMware Related Device Drivers
if dmesg | grep -i 'Manufacturer: VMware' >/dev/null; then
    vmware_dmesg_found=true
fi
# Check 'dmidecode chassis asset tag' For Azure HCI 
if dmidecode --string chassis-asset-tag | grep -i 2590-0674-1028-0286-5967-9235-45 >/dev/null; then
    azurehci_assettag_found=true
fi
# Check for hyper-v  
if dmesg | grep -i 'hyper-v' >/dev/null; then
    azure_demesg_found=true
fi
# Check 'dmidecode chassis asset tag' For Azure Cloud  
if dmidecode --string chassis-asset-tag | grep -i 7783-7084-3265-9085-8269-3286-77 >/dev/null; then
   azurecloud_assettag_found=true
fi
# Check 'dmidecode asset tag' For Oracle Cloud  
if dmidecode | grep -i oracle >/dev/null; then
   oraclecloud_assettag_found=true 
fi
# Check for KVM In The System Manufacturer (dmidecode)
if dmidecode -s system-manufacturer | grep -i 'kvm'; then
    kvm_found=true
fi
#########################################################
############Identify Virtualization Client###############
if   [ "$qemu_found" = true ]; then
    print_info "Virtualization Client: Proxmox"
elif [ "$vmware_dmesg_found" = true ]; then
    print_info "Virtualization Client: VMware"
elif [ "$azurehci_assettag_found" = true ] && [ "$azure_demesg_found" = true ]; then
	print_info "Virtualization Client: Azure HCI"
elif [ "$azurecloud_assettag_found" = true ] && [ "$$azure_demesg_found" = true ] ; then
    print_info "Virtualization Client: Azure Cloud"
elif [ "$oraclecloud_assettag_found" = true ]; then
    print_info "Virtualization Client: Oracle Cloud"
elif [ "$kvm_found" = true ]; then
    print_info "Virtualization Client: OLVM/KVM"
else
    print_info "No recognized virtualization client found."
fi
#########################################################
###########Get Linux Distribution and Version############                    
if [ -f /etc/os-release ]; then
    . /etc/os-release
    print_info "Linux Distribution: $NAME"
    print_info "Version: $VERSION"
else
    print_info "Distribution Information Not Found."
fi
# Pull and display the kernel version
kernel_version=$(uname -r)
print_info "Kernel Version: $kernel_version"

