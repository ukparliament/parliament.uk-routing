#!/bin/sh

#while ! nc -z rabbitmq 5672; do sleep 3; done

mkdir -p /var/lib/varnish/`hostname` && chown nobody /var/lib/varnish/`hostname`

# Convert environment variables in the conf to fixed entries
# http://stackoverflow.com/questions/21056450/how-to-inject-environment-variables-in-varnish-configuration
for name in UTILITIES_BACKEND_IP UTILITIES_BACKEND_PORT LIST_BACKEND_IP LIST_BACKEND_PORT THING_BACKEND_IP THING_BACKEND_PORT
do
    eval value=\$$name
    sed -i "s|\${${name}}|${value}|g" /etc/varnish/default.vcl
done

# Start varnish and log
varnishd -f /etc/varnish/default.vcl -s malloc,100M -a 0.0.0.0:${VARNISH_PORT}
varnishlog