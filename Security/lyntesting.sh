#!/usr/bin/env bash

 # Run comprehensive Lynis audit

read -r -p "Enter the system audit report name: " report_name
echo " "
read -r -p "Enter the system pentest report name: " pentest_name

run_audit(){
  # append a .txt file to the report name, and increment the report number each time the audit is run
  # if the report number is not provided, start at 1,then check if the file already exists each time the audit is run
    lynis audit system --verbose --log-file /var/log/lynis/hardn-audit.log --report-file /var/log/lynis/hardn-report.dat 2>/dev/null > "${report_name}_${report_number}.txt"
    report_number=$((report_number+1))
    echo "Report generated: ${report_name}_${report_number}.txt"
    #${report_name}_${report_number}.txt
}

wait(){
  # wait 5 seconds before running the next function
  sleep 5
}

 # Run Lynis with pentest profile for additional checks
 run_pentest(){
  # append a .txt file to the report name, and increment the report number each time the audit is run
    lynis audit system --pentest --verbose --log-file /var/log/lynis/hardn-pentest.log 2>/dev/null > "${pentest_name}_${report_number}.txt"
    pentest_number=$((pentest_number+1))
    echo "Pentest report generated: ${pentest_name}_${pentest_number}.txt"
    #${pentest_name}_${pentest_number}.txt
}

# call the functions
run_audit
wait
run_pentest
