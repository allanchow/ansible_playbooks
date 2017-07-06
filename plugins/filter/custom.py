# -*- coding: utf-8 -*-
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import socket

from jinja2 import Environment, FileSystemLoader
from ansible import errors
from ansible.plugins.filter import ipaddr

def _string_sanity_check(string):
    if string is None:
        return ''
    if not isinstance(string, basestring):
        return str(string)
    return string

def lpad(string, width, fillchar=' '):
    sanitzed_string = _string_sanity_check(string)
    return sanitzed_string.rjust(width, fillchar)

def repeat(string, count, separator=None):
    sanitzed_string = _string_sanity_check(string)
    sanitzed_count = int(count)
    if separator is None:
        return sanitzed_count * sanitzed_string
    sanitzed_separator = str(separator)
    return (sanitzed_count * (sanitzed_string + str(sanitzed_separator)))[:-len(sanitzed_separator)]

def wrap(value, wrapper = '"'):
    return wrapper + value + wrapper

def resolve(value):
    ip = ipaddr.ipaddr(value)
    try:
        return ip != False and ip or socket.gethostbyname(value)
    except socket.gaierror:
        return False

class FilterModule(object):

    def filters(self):
        return {
            'lpad': lpad,
            'repeat': repeat,
            'wrap': wrap,
            'resolve': resolve,
        }
