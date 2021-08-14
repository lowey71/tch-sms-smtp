#!/bin/sh

MAILSERVER=192.168.1.100
FROM=sms@fakehost.localdomain
TO=testuser@fakehost.localdomain
RETRY=30

func_process_msg () {
  ubus call mobiled.sms get | jsonfilter -e '@.messages[*]' | while read msg
  do
    id=`echo $msg | jsonfilter -e '$.id'`
    number=`echo $msg | jsonfilter -e '$.number'`
    text=`echo $msg | jsonfilter -e '$.text'`
    date=`echo $msg | jsonfilter -e '$.date'`
    echo "id: $id, number: $number, text: $text, date: $date"
    while true
    do
      lua smtp.lua $MAILSERVER $FROM $TO "SMS Message from $number" "$text" && break
      echo "ERROR: SMTP Send failed ${date} Retry in $RETRY sec"
      sleep $RETRY
    done
    ubus call mobiled.sms delete "{\"id\":$id}"
  done
}

#clear message queue first
func_process_msg

#listen for events
ubus listen mobiled mobiled.sms | while read line
do
  echo $line | jsonfilter -e '@.mobiled.event'  && func_process_msg
done
