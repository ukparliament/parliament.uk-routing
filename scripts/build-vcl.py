#! /usr/bin/env python3

import json
import os
import re
import sys
import urllib.request

# Set this to False if you want to use Varnish for load balancing
USE_ALBS = False

def get_cluster_name():
    # Get the IP address of the container
    f = os.popen('ip route show')
    data = f.read()
    f.close()
    lines = data.splitlines()
    expr = r'(?:\d+\.){3}\d+'
    match = re.search(expr, lines[0])
    ipaddr = match.group()
    # Now get the container instance metadata
    url = 'http://{0}:51678/v1/metadata'.format(ipaddr)
    req = urllib.request.Request(url)
    resp = urllib.request.urlopen(req).read()
    data = json.loads(resp.decode('utf-8'))
    return data['Cluster']

def get_vcl_aws():
    tasks = []
    if USE_ALBS:
        from vclbuilder.albs import list_tasks
        tasks = list_tasks()
    if not tasks:
        from vclbuilder.tasks import list_tasks
        cluster = get_cluster_name()
        tasks = list_tasks(cluster)

    from vclbuilder.vcl import VclFile
    vclfile = VclFile()
    for task in tasks:
        vclfile.add_backend(task)
    return vclfile.get_vcl()

def get_vcl_docker():
    import os
    import os.path
    from string import Template

    with open(os.path.join(os.path.dirname(__file__), 'compose.tpl')) as f:
        txt = f.read()
    tpl = Template(txt)
    return tpl.substitute(os.environ)

def get_vcl(is_aws):
    if is_aws:
        return get_vcl_aws()
    else:
        return get_vcl_docker()


if __name__ == '__main__':
    is_aws = ('-a' in sys.argv) or ('--aws' in sys.argv)
    print(get_vcl(is_aws))
