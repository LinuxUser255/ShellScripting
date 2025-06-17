#!/usr/bin/env bash

 # Run comprehensive Lynis audit

read -r -p "Enter the system audit audit name: " audit_name
echo " "
read -r -p "Enter the system pentest audit name: " pentest_name

run_audit(){
  # append a .txt file to the audit name, and increment the audit number each time the audit is run
  # if the audit number is not provided, start at 1,then check if the file already exists each time the audit is run
    lynis audit system --verbose --log-file /var/log/lynis/hardn-audit.log --audit-file /var/log/lynis/hardn-audit.dat 2>/dev/null > "${audit_name}_${audit_number}.txt"
    audit_number=$((audit_number+1))
    echo "Report generated: ${audit_name}_${audit_number}.txt"
    #${audit_name}_${audit_number}.txt
}

wait(){
  # wait 5 seconds before running the next function
  sleep 5
}

 # Run Lynis with pentest profile for additional checks
 run_pentest(){
  # append a .txt file to the audit name, and increment the audit number each time the audit is run
    lynis audit system --pentest --verbose --log-file /var/log/lynis/hardn-pentest.log 2>/dev/null > "${pentest_name}_${audit_number}.txt"
    pentest_number=$((pentest_number+1))
    echo "Pentest audit generated: ${pentest_name}_${pentest_number}.txt"
    #${pentest_name}_${pentest_number}.txt
}

# call the functions
run_audit
wait
run_pentest
