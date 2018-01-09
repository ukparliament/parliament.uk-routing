#!/bin/sh

function init_docker_compose() {
    cat <<EOF > /vcl/backends.vcl
import directors;

backend lists_server {
    .host = "$LIST_BACKEND_IP";
    .port = "$LIST_BACKEND_PORT";
}

backend things_server {
    .host = "$THING_BACKEND_IP";
    .port = "$THING_BACKEND_PORT";
}

backend utilities_server {
    .host = "$UTILITIES_BACKEND_IP";
    .port = "$UTILITIES_BACKEND_PORT";
}

sub init_backends {
    new lists = directors.round_robin();
    lists.add_backend(lists_server);
    new things = directors.round_robin();
    things.add_backend(things_server);
    new utilities = directors.round_robin();
    utilities.add_backend(utilities_server);
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