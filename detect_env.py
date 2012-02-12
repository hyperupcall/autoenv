#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os



def find_above(*names):
    """Attempt to locate a .env file by searching parent dirs."""

    path = '.'

    found = []

    while os.path.split(os.path.abspath(path))[1]:
        for name in names:
            joined = os.path.join(path, name)
            if os.path.exists(joined):
                found.insert(0, os.path.abspath(joined))
        path = os.path.join('..', path)

    return found


if __name__ == '__main__':

    # Is there an .env file?
    envfiles = find_above('.env')

    for envfile in envfiles:
        # Do it live!
        print 'source %s' % envfile
