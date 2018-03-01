#! /bin/sh

function reconfigure {
    echo "Backends have changed - reconfiguring Varnish"
    # Generate a unique timestamp ID for this version of the VCL
    TIME=$(date +%s)
    # Load the file into memory
    varnishadm vcl.load varnish_$TIME /etc/varnish/default.vcl
    # Active this Varnish config
    varnishadm vcl.use varnish_$TIME
    sha1sum /vcl/backends.vcl > /vcl/.backends.vcl.sha1
}

python3 /scripts/build-vcl.py -a > /vcl/backends.vcl

if ! [ -f /vcl/.backends.vcl.sha1 ]; then
    reconfigure
elif ! sha1sum -c /vcl/.backends.vcl.sha1 > /dev/null 2> /dev/null; then
    reconfigure
fi
