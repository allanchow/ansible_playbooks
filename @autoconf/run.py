#!/usr/bin/env python
# -*- coding: utf-8 -*-

import socket
import sys
import os
import typing
import argparse
import collections

try:
    import ansible                  # type: ignore
except ImportError:
    print('Ansible is required')
    sys.exit(1)

if __name__ == '__main__':
    def versiontuple(v):            # type: (str) -> Tuple(int)
        return tuple(map(int, (v.split("."))))
    assert versiontuple(ansible.__version__)[:2] >= (2, 2), 'Ansible minium version required: >= 2.2'
    __py_ver = sys.version_info[:2]
    assert __py_ver >= (2, 7) and __py_ver < (3, 0), 'Python minium version required: >= 2.7, and < 3.0'

    __parser = argparse.ArgumentParser(description='Auto Deployment')
    group = __parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--prod', action='store_true', help='Deploy to production CDN')
    group.add_argument('--dev', action='store_true', help='Deploy to uat CDN')
    group.add_argument('--local', action='store_true', help='Deploy to localhost for testing')
    __parser.add_argument('--dryrun', action='store_true', help='Run in dryrun mode without touching any targeted server config')
    __pargs = __parser.parse_known_args()

    dryrun = __pargs[0].dryrun

    __varset = collections.namedtuple('__varset', ['inv_deploy'])
    if __pargs[0].prod:
        port = 10000
        env = __varset('all_cdn')
    elif __pargs[0].dev:
        port = 11000
        env = __varset('all_tb_cdn')
    elif __pargs[0].local:
        port = 12000
        env = __varset('localhost')
    else:
        __parser.print_help()
        sys.exit()

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_address = ('localhost', port)
    try:
        if not dryrun:
            sock.bind(server_address)


        __script_path = os.path.dirname(os.path.realpath(__file__))
        ansible_extra_vars = ['-e %s=%s' % (k, v) for k, v in env.__dict__.iteritems()]
        ansible_extra_vars.append('-e dryrun=%s' % dryrun)
        import subprocess        
        env = os.environ
        env.update({'PATH': '%s:/usr/bin:/bin:/sbin:/usr/local/bin' % env['PATH']})
        subprocess.call(["/usr/bin/env", "ansible-playbook", "%s/%s" % (__script_path, "main.yml")] + ansible_extra_vars + __pargs[1], cwd=__script_path, env=env)
        #print(["/usr/bin/env", "ansible-playbook", "%s/%s" % (__script_path, "main.yml")] + ansible_extra_vars + __pargs[1])
        sock.close()
    except socket.error:
        sys.stderr.write('Only one Playbook instance can be running / port %s cannot be bind\n' % port)
        sys.exit(1)
