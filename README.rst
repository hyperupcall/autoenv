Autoenv: Directory-based Environments
======================================

Magic per-project environments. How pretentious.


What is it?
-----------

If a directory contains ``.env`` file, it will automatically be excecuted
when you ``cd`` into it.

This is great for...

- auto-activating virtualenvs
- project-specific environment variables
- making millions

You can also nest envs within eachother. How awesome is that!?

Usage
-----

Follow the white rabbit::

    $ touch project/.env
    $ echo "echo 'woah'" > project/.env
    $ cd project
    woah


Install
-------

Install it easily::

    $ git clone git@github.com:kennethreitz/autoenv.git ~/.autoenv
    $ echo 'source ~/.autoenv/activate.sh' > ~/.bashrc


Disclaimer
----------

Autoenv overrides ``cd``. If you already do this, invoke ``autoenv-init`` within your custom ``cd``.

Be a rebel.
