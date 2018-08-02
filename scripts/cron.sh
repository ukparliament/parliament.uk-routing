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

### Set the maximum number of VCLs that can remain loaded
MAX_VCLS=25
VCL_LIST=$(varnishadm vcl.list)
awk_vcl_list() {
        printf '%s' "$VCL_LIST" | awk "$@"
}
find_vcls_loaded() {
        awk_vcl_list 'NF == 4 &&
                $1 == "available" &&
                $4 != "boot" {print $4}'
}
AVAILABLE=$(find_vcls_loaded | wc -l)
if [ "$MAX_VCLS" -lt "$AVAILABLE" ]
then
DISCARDED=$((AVAILABLE - MAX_VCLS))
find_vcls_loaded |
head -n "$DISCARDED" |
while read -r DISCARD_NAME
do
        varnishadm vcl.discard "$DISCARD_NAME" >/dev/null
done
fi
