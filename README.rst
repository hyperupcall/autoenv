Autoenv: Directory-based Environments
======================================

Magic per-project shell environments. Very pretentious.


What is it?
-----------

If a directory contains a ``.env`` file, it will automatically be executed
when you ``cd`` into it.

If a directory contains a ``.unenv`` file, it will automatically be executed
when you ``cd`` out of it.

This is great for...

- `auto-activating virtualenvs <https://github.com/kennethreitz/autoenv/wiki/Cookbook>`_
- project-specific environment variables
- making millions

`Foreman <https://github.com/ddollar/foreman>`_ env files are completely compatible.

You can also nest envs within eachother. How awesome is that!?

Usage
-----

Follow the white rabbit::

    $ touch project/.env
    $ echo "echo 'woah'" > project/.env
    $ cd project
    woah


.. image:: http://media.tumblr.com/tumblr_ltuzjvbQ6L1qzgpx9.gif


Install
-------

Install it easily:

Mac OS X Using Homebrew
~~~~~~~~~~~~~~~~~~~~~~~

::

    $ brew install autoenv


Using pip
~~~~~~~~~

::

    $ pip install autoenv


Using git
~~~~~~~~~

::

    $ git clone git://github.com/kennethreitz/autoenv.git ~/.autoenv
    $ echo 'source ~/.autoenv/activate.sh' >> ~/.bashrc


Disclaimer
----------

Autoenv overrides ``cd``. If you already do this, invoke ``autoenv_init`` within your custom ``cd`` after sourcing ``activate.sh``.


Testing
-------

Install the test runner::

    $ make
    gem install dtf --version 0.1.2
    Successfully installed dtf-0.1.2

Test::

    $ make test
    dtf tests/*
    ............
    ##### Processed commands 14 of 14, success tests 12 of 12.
