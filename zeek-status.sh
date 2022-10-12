#/bin/bash
processes=$(zeekctl status | wc -l)
workers="$(($processes-1))"
#output=$(zeekctl status | awk 'NR>1 {print $4}')

#echo $workers
#echo $output

for ((i=0; i<$workers; i++));
do
name=$(zeekctl status | awk 'NR==v1 {print $1}' v1="$((${i}+2))")
stat=$(zeekctl status | awk 'NR==v1 {print $4}' v1="$((${i}+2))")
if [ "$stat" != "running" ]; then
    echo "$name $stat. restarting..."
    zeekctl stop $name
    wait
    zeekctl start $name
    sleep 30
    echo "Checking Status"
    curstat=$(zeekctl status | awk 'NR==v1 {print $4}' v1="$((${i}+2))")
    echo "$curstat"
    if ["$curstat" != "running"]; then
        echo "Restart of $name failed to return as running. Restarting Zeek."
        zeekctl stop
        wait
        zeekctl deploy
        wait
        echo "Restart complete."
    else
        #./cron-status-zeek-workers.sh
        msg=$(zeekctl status | awk 'NR==v1 {print $1, $4}' v1="$((${i}+2))")
        echo "Status has changed to: $msg"
        echo "Restart complete."
    fi
fi

done
