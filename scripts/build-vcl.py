#! /usr/bin/env python3

import sys

def get_vcl_aws():
    from vclbuilder.tasks import list_tasks
    from vclbuilder.vcl import VclFile

    tasks = list_tasks('ecs')
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
