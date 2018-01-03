#! /usr/bin/env python3

import os
import sys

from vclbuilder.tasks import list_tasks
from vclbuilder.vcl import VclFile

def get_vcl():

    tasks = list_tasks('ecs')
    vclfile = VclFile()
    for task in tasks:
        vclfile.add_backend(task)
    return vclfile.get_vcl()

if __name__ == '__main__':
    print(get_vcl())
