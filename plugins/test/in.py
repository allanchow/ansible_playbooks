# -*- coding: utf-8 -*-
def _in(a, b):
    return a in b

def _is_empty_string(str):
    return str.strip() == ''

class TestModule(object):
    def tests(self):
        return {
            'in': _in,
            'is_empty_string': _is_empty_string
        }
