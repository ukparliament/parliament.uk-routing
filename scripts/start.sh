#! /bin/sh

if [ -n "$LIST_BACKEND_IP" ]; then
    # Running in docker compose
    python3 /scripts/build-vcl.py > /vcl/backends.vcl
else
    # Running in AWS
    init_aws_ecr
    mkdir -p ~/.aws
    cat <<EOF > ~/.aws/config
[default]
region=eu-west-1
EOF
    chmod -R go-rwx ~/.aws
    python3 /scripts/build-vcl.py -a > /vcl/backends.vcl
fi

mkdir -p /var/lib/varnish/`hostname` && chown nobody /var/lib/varnish/`hostname`

# Start varnish and log
varnishd -f /etc/varnish/default.vcl -s malloc,100M -a 0.0.0.0:${VARNISH_PORT}
varnishlog