#!/usr/bin/env bash

# Change Internal Field Separator to split on newlines only
IFS="
"

basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! -e $basedir/devstack/stack-screenrc ]; then
    echo "$basedir/devstack/stack-screenrc not found.  Did stack.sh fail?"
    exit 1
fi

for line in `cat $basedir/devstack/stack-screenrc |tr -d "\r"`; do
    if  [[ $line == stuff* ]]; then
        echo
        # Extract the command line to run this service
        command=`echo "$line" |sed 's/^stuff //;s/"//g'`
        base_command=`echo $command |sed 's:.*bin/::;s/ .*//'`

        # Skip screen sessions that are only a tail command
        [[ $command == *tail* ]] && continue

        # Find a good log directory by first determining the parent
        #+ Openstack service (nova, glance, etc.)
        parent=`echo "$base_command" |cut -d- -f1`

        logdir="/var/log/`basename $parent`"
        logfile="$base_command.log"

        # Now, create the upstart script from this template
        echo "Creating /etc/init/$base_command.conf"

        cat > "/etc/init/$base_command.conf" <<EOF
description "$base_command server"

start on (filesystem and net-device-up IFACE!=lo)
stop on runlevel [016]

pre-start script
    mkdir -p $logdir
    chown $unpriv_user:root $logdir
end script

respawn

exec su -c "$command --log-dir=$logdir --log-file=$logfile" $unpriv_user
EOF

    # Swift processes do not support logfiles, so modify the init script
    if [ `echo "$command" |grep -c swift` = 1 ]; then
        sed -i 's/--log.*"/"/' /etc/init/$base_command.conf
    fi
    # Fire up the service
    service $base_command restart
    fi
done

exit 0
