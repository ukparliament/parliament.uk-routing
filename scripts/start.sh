#! /bin/sh

if [ -n "$LIST_BACKEND_IP" ]; then
    # Running in docker compose
    python3 /scripts/build-vcl.py > /vcl/backends.vcl
else
    # Running in AWS
    mkdir -p ~/.aws
    cat <<EOF > ~/.aws/config
[default]
region=eu-west-1
EOF
    chmod -R go-rwx ~/.aws
    python3 /scripts/build-vcl.py -a > /vcl/backends.vcl

    # Set up cron job
    env > /scripts/env
    tmpfile=$(mktemp)
    crontab -l > $tmpfile
    echo "* * * * * env - \$(cat /scripts/env) /scripts/cron.sh 2>&1 | /usr/bin/logger -t reconfigure" >> $tmpfile
    crontab $tmpfile
    rm $tmpfile
fi

mkdir -p /var/lib/varnish/`hostname` && chown nobody /var/lib/varnish/`hostname`

# Start varnish and log
varnishd -f /etc/varnish/default.vcl -s malloc,100M -a 0.0.0.0:${VARNISH_PORT}
varnishlog