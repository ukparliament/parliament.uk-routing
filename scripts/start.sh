#!/bin/sh

function init_docker_compose() {
    cat <<EOF > /vcl/backends.vcl
backend lists {
    .host = "$LIST_BACKEND_IP";
    .port = "$LIST_BACKEND_PORT";
}

backend things {
    .host = "$THING_BACKEND_IP";
    .port = "$THING_BACKEND_PORT";
}

backend utilities {
    .host = "$UTILITIES_BACKEND_IP";
    .port = "$UTILITIES_BACKEND_PORT";
}

sub init_backends {
}
EOF
    chmod +x /vcl/backends.vcl
}


function init_aws_ecr() {
    mkdir -p ~/.aws
    cat <<EOF > ~/.aws/config
[default]
region=eu-west-1
EOF
    chmod -R go-rwx ~/.aws
    python3 /scripts/build-vcl.py > /vcl/backends.vcl
}


if [ -n "$LIST_BACKEND_IP" ]; then
    init_docker_compose
else
    init_aws_ecr
fi


mkdir -p /var/lib/varnish/`hostname` && chown nobody /var/lib/varnish/`hostname`

# Start varnish and log
varnishd -f /etc/varnish/default.vcl -s malloc,100M -a 0.0.0.0:${VARNISH_PORT}
varnishlog