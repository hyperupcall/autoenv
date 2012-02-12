#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os



def find_above(*names):
    """Attempt to locate a .env file by searching parent dirs."""

    path = '.'

    while os.path.split(os.path.abspath(path))[1]:
        for name in names:
            joined = os.path.join(path, name)
            if os.path.exists(joined):
                return os.path.abspath(joined)
        path = os.path.join('..', path)


if __name__ == '__main__':

    if 'AUTOENV_ACTIVE' not in os.environ:

        # Is there an .env file?
        envfile = find_above('.env')

        if envfile:
            # Do it live!
            print 'export AUTOENV_ACTIVE'
            print 'source %s' % envfile
