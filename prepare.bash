#!/bin/bash

set -x

function dn() { return 0; } #Do Nothing.
function fdt() { date +%Y%m%d%H%M:%S:%N; }
function output() { echo -e "`fdt`:\e[92m$@\e[0m"; }


output "--- Install Packages ---"

dnf install -y epel-release
dnf config-manager --set-enabled crb

# dnf -q -y --nogpgcheck install gcc gcc-c++ libstdc++-devel libaio libaio-devel \
# tree wget curl net-tools gdb

# dnf clean all

PACKAGES="gcc gcc-c++ libstdc++-devel libaio libaio-devel tree wget net-tools gdb"
FAILED=""

for pkg in $PACKAGES; do
    echo "Installing $pkg ..."
    if ! dnf install -y --nogpgcheck $pkg; then
        FAILED="$FAILED $pkg"
    fi
done

if [ -n "$FAILED" ]; then
    echo "ERROR1111: Failed to install packages:$FAILED" >&2
    exit 1
fi

MISSING=""

for pkg in $PACKAGES; do
  if ! rpm -q $pkg &>/dev/null; then
    MISSING="$MISSING $pkg"
  fi
done

if [ -n "$MISSING" ]; then
  echo "ERROR2222: The following packages are NOT installed:$MISSING" >&2
  exit 1
fi

output "--- Creating Users and Groups ---"

groupadd -g 500 dba
useradd -g dba tibero