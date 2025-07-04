#!/bin/bash

function dn() { return 0; } #Do Nothing.
function fdt() { date +%Y%m%d%H%M:%S:%N; }
function output() { echo -e "`fdt`:\e[92m$@\e[0m"; }

# Tibero .bash_profile
export TB_SID=tibero
export TB_HOME=/home/tibero/tibero7
export TB_CONFIG=$TB_HOME/config
export PATH=$PATH:$TB_HOME/bin:$TB_HOME/client/bin
export LD_LIBRARY_PATH=$TB_HOME/lib:$TB_HOME/client/lib

if [ -f $TB_CONFIG/tibero.tip ]; then
	echo "tibero.tip exists, skipping init."
	output "--- Executing tbboot ---"
    $TB_HOME/bin/tbboot
else

output "--- Executing $TB_CONFIG/gen_tip.sh ---"
$TB_CONFIG/gen_tip.sh

output "--- Executing tbboot nomount ---"
$TB_HOME/bin/tbboot nomount

output "--- Executing tbsql $TB_HOME/createDatabase.sql---"
tbsql sys/tibero @"$TB_HOME/createDatabase.sql"

output "--- Executing tbboot ---"
$TB_HOME/bin/tbboot

output "--- Executing system_install ---"
$TB_HOME/scripts/system_install.sh -p1 tibero -p2 syscat

output "--- Executing tbsql $TB_HOME/createDemoUser.sql---"
tbsql sys/tibero @"$TB_HOME/createDemoUser.sql"

#tbdown immediate

fi

sleep 5

tail -f "$TB_HOME/instance/$TB_SID/log/slog/sys.log"