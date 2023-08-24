#!/bin/bash
pid_file="test.pid"
curr_date=$(date '+%d/%b/%Y:%H:%M:%S')
log_file="/var/log/httpd/access_log"
err_file="/var/log/httpd/error_log"

if [ -f $pid_file ]; then
  pgrep -F $pid_file
  [[ $? -eq 1 ]] && rm $pid_file || exit
else 
  echo $$ > $pid_file
fi

my_str=$(grep -wn "SCRIPT_WAS_HERE" $log_file | cut -d: -f1) 
if [ -z "$my_str" ]; then
  top_ip=$(awk '{print $1}' $log_file | sort | uniq -c | sort -rn | head -n5)
  top_url=$(awk '{print $7}' $log_file | sort | uniq -c | sort -rn | head -n5)
  top_codes=$(awk '{print $9}' $log_file | sort | uniq -c | sort -rn | head -n5)
else
  my_str=$(($my_str+1))
  top_ip=$(tail +$my_str $log_file | awk '{print $1}' | sort | uniq -c | sort -rn | head -n5)
  top_url=$(tail +$my_str $log_file | awk '{print $7}' | sort | uniq -c | sort -rn | head -n5)
  top_codes=$(tail +$my_str $log_file | awk '{print $9}' | sort | uniq -c | sort -rn | head -n5)
  sed -i "/^SCRIPT_WAS_HERE$/d" $log_file
fi

last_date=$(tail -n1 $log_file | awk '{print $4}' | cut -c 2-) 

my_str_err=$(grep -wn "SCRIPT_WAS_HERE" $err_file | cut -d: -f1)
if [ -z "$my_str_err" ]; then
  errors=$(cat $err_file)
else
  my_str_err=$(($my_str_err+1))
  errors=$(tail +$my_str_err $err_file)
  sed -i "/^SCRIPT_WAS_HERE$/d" $err_file
fi

printf "\nSCRIPT_WAS_HERE" >> $log_file
printf "\nSCRIPT_WAS_HERE" >> $err_file
printf "Report from $last_date until $curr_date\n\nTOP 5 IPs\n$top_ip\nTOP 5 URLs\n$top_url\nTOP 5 HTTP CODES\n$top_codes\n\nErrors\n$errors\n" > mail.txt
mail -s "Another One Report" test@gmail.com < mail.txt




#top_ip=$(awk '{print $1}' $log_file | sort | uniq -c | sort -rn | head -n5)
#top_url=$(awk '{print $7}' $log_file | sort | uniq -c | sort -rn | head -n5)
#last_date=$(tail -n2 $log_file | awk '{print $4}' | cut -c 2-)
#tail -n2 /home/user/bash_vm/log.txt | awk '{print $4}' | cut -c 2- 
#last_line_date=$(awk '{print $4}' $last_line | sed 's/^[//')
#printf "last date: $last_date\n"
#printf "result is \n$top_ip\n\n$top_url\n"
#printf "SCRIPT_WAS_HERE\n" >> $log_file
#sleep 50
rm $pid_file


#date '+%d/%b/%Y:%H:%M:%S' -> log date format
#awk '{print $4}' /home/user/bash_vm/log.txt | sort | uniq -c | sort -rn | head -n5 -> DATE
#awk '{print $9}' /home/user/bash_vm/log.txt | sort | uniq -c | sort -rn | head -n5 -> CODES