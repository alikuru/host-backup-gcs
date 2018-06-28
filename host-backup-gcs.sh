#!/bin/bash
# Basic shell script for creating regular file backups for Unix/Linux based OSes
# Check settings.conf for details
# Copyright (C) 2018 Ali Kuru - All Rights Reserved
# Permission to copy and modify is granted under the MIT license

# Get date for tagging backups.
suffix=$(date +"%Y%m%d")

# Set path and logging details
scriptpath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
logfile="backup-$(hostname)-$suffix.log"
exitcodes="exit-codes.log"

if [[ -f $scriptpath/settings.conf ]]; then

    source $scriptpath/settings.conf

    if [[ -z "$gs_sync_exclude" ]]; then
        for dir in "${backup_dirs[@]}"
        do
            gsutil -m rsync $gs_sync_params "$dir" gs://$gs_bucket/$(hostname)/"$(basename "$dir")" 2>> $scriptpath/$logfile
        done
    else
        for dir in "${backup_dirs[@]}"
        do
            gsutil -m rsync $gs_sync_params -x "$gs_sync_exclude" "$dir" gs://$gs_bucket/$(hostname)/"$(basename "$dir")" 2>> $scriptpath/$logfile
        done
    fi
    echo $? >> $scriptpath/$exitcodes

    # Check if any errors happened during creating and synchronizing backups.
    errorcount="$(grep -Ev '(^0|^$)' $scriptpath/$exitcodes|wc -l)"

    # Send the report.
    report=$(openssl enc -base64 -A -in $scriptpath/$logfile)
    if [[ $errorcount -eq 0 ]]; then
        errorstatus="without any errors"
    elif [[ $errorcount -eq 1 ]]; then
        errorstatus="with $errorcount error"
    else
        errorstatus="with $errorcount errors"
    fi

    echo "{From: '$mail_from', To: '$mail_to', Subject: 'Backup completed $errorstatus @ $(date) for $(hostname)', HtmlBody: 'Please find job report attached to this email.', TextBody: 'Please find job report attached to this email.', Attachments: [{Name: '$logfile', Content: '$report', ContentType: 'text/plain'}]}" >> $scriptpath/mail.json
    curl "https://api.postmarkapp.com/email" \
        -X POST \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -H "X-Postmark-Server-Token: $postmark_token" \
        -d @$scriptpath/mail.json

    # Set trap for cleanup
    function cleanup {
        rm $scriptpath/$logfile $scriptpath/$exitcodes $scriptpath/mail.json
    }
    trap cleanup EXIT

else
    echo "Missing settings.conf file, please refer to README." > error-$(hostname)-$suffix.log
    exit 0
fi
