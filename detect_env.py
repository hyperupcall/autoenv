#!/usr/bin/env python
# -*- coding: utf-8 -*-


import os


def find_above(*names):
    """Attempt to locate a .workon file by searching parent dirs."""

    path = '.'

    while os.path.split(os.path.abspath(path))[1]:
        for name in names:
            joined = os.path.join(path, name)
            if os.path.exists(joined):
                return os.path.abspath(joined)
        path = os.path.join('..', path)


if __name__ == '__main__':

    # Is there a .workon file?
    wo_file = find_above('.env')

    # If there is, and we're not already in a virtualenv.
    if wo_file and not 'VIRTUAL_ENV' in os.environ:
        with open(wo_file) as f:

            # Grab the venv path
            venv_path = f.readlines()[0].strip()

            # Activate!
            print('source {0}/bin/activate'.format(venv_path))

            # Mark it as ours.
            print('export AUTOVIRTUALENV')

    # If there's no file, bur we're in a virtualenv...
    elif (not wo_file) and ('VIRTUAL_ENV' in os.environ.keys()):

        # ... and if it's ours.
        if '_ACTIVE' in os.environ:

            # Deactivate the env.
            print('deactivate')
            print('unset AUTOVIRTUALENV')
