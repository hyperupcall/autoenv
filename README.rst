Autoenv: Directory-based Environments
======================================

Magic per-project shell environments. Very pretentious.


What is it?
-----------

If a directory contains a ``.env`` file, it will automatically be executed
when you ``cd`` into it.

This is great for...

- auto-activating virtualenvs
- project-specific environment variables
- making millions

You can also nest envs within each other. How awesome is that!?

When executing, autoenv, will walk up the directories until the mount point and execute all ``.env`` files beginning at the top.

Usage
-----

Follow the white rabbit::

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
    $ echo 'source $(brew --prefix autoenv)/activate.sh' >> ~/.bash_profile


Using pip
~~~~~~~~~

::

    $ pip install autoenv
    $ echo "source `which activate.sh`" >> ~/.bashrc


Using git
~~~~~~~~~

::

    $ git clone git://github.com/kennethreitz/autoenv.git ~/.autoenv
    $ echo 'source ~/.autoenv/activate.sh' >> ~/.bashrc


Using AUR
~~~~~~~~~

Arch Linux users can install `autoenv<https://aur.archlinux.org/packages/autoenv/>` or `autoenv-git<https://aur.archlinux.org/packages/autoenv-git/>` with their favorite AUR helper.
You need to source activate.sh in your bashrc afterwards:

::
    $ echo 'source ~/.autoenv/activate.sh' >> ~/.bashrc


Configuration
-------------

Before sourcing activate.sh, you can set the following variables:

- ``AUTOENV_AUTH_FILE``: Authorized env files, defaults to ``~/.autoenv_authorized``
- ``AUTOENV_ENV_FILENAME``: Name of the ``.env`` file, defaults to ``.env``
- ``AUTOENV_LOWER_FIRST``: Set this variable to flip the order of ``.env`` files exectued

Shells
------

autoenv is tested on:

- bash
- zsh
- dash
- more to come


Disclaimer
----------

Autoenv overrides ``cd``. If you already do this, invoke ``autoenv_init`` within your custom ``cd`` after sourcing ``activate.sh``.

Autoenv can be disabled via ``unset cd`` if you experience I/O issues with
certain file systems, particularly those that are FUSE-based (such as 
``smbnetfs``).
