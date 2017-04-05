Autoenv: Directory-based Environments
======================================

Magic per-project shell environments. Very pretentious.


What is it?
-----------

If a directory contains a ``.env`` file, it will automatically be executed
when you ``cd`` into it. When enabled (set ``AUTOENV_ENABLE_LEAVE`` to a non-null string),
if a directory contains a ``.env.leave`` file, it will automatically be executed when you leave it.

This is great for...

- auto-activating virtualenvs
- auto-deactivating virtualenvs
- project-specific environment variables
- making millions

You can also nest envs within each other. How awesome is that!?

When executing, autoenv, will walk up the directories until the mount point and execute all ``.env`` files beginning at the top.

Usage
-----

Follow the white rabbit::

    $ echo "echo 'whoa'" > project/.env
    $ cd project
    whoa


.. image:: http://media.tumblr.com/tumblr_ltuzjvbQ6L1qzgpx9.gif


Install
-------

Install it easily:

Mac OS X Using Homebrew
~~~~~~~~~~~~~~~~~~~~~~~

::

    $ brew install autoenv
    $ echo "source $(brew --prefix autoenv)/activate.sh" >> ~/.bash_profile


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

Arch Linux users can install `autoenv <https://aur.archlinux.org/packages/autoenv/>`_ or `autoenv-git <https://aur.archlinux.org/packages/autoenv-git/>`_ with their favorite AUR helper.

You need to source activate.sh in your bashrc afterwards:

::

    $ echo 'source /usr/share/autoenv/activate.sh' >> ~/.bashrc


Configuration
-------------

Before sourcing activate.sh, you can set the following variables:

- ``AUTOENV_AUTH_FILE``: Authorized env files, defaults to ``~/.autoenv_authorized``
- ``AUTOENV_ENV_FILENAME``: Name of the ``.env`` file, defaults to ``.env``
- ``AUTOENV_LOWER_FIRST``: Set this variable to flip the order of ``.env`` files executed
- ``AUTOENV_ENV_LEAVE_FILENAME``: Name of the ``.env.leave`` file, defaults to ``.env.leave``
- ``AUTOENV_ENABLE_LEAVE``: Set this to a non-null string in order to enable source env when leaving

Shells
------

autoenv is tested on:

- bash
- zsh
- dash
- fish is supported by `autoenv_fish <https://github.com/loopbit/autoenv_fish>`_
- more to come

Alternatives
------------

Direnv is an excellent alternative to autoenv, and includes the ability to unset environment variables as well. It also supports the fish terminal. 

`https://direnv.net <https://direnv.net>`_


Disclaimer
----------

Autoenv overrides ``cd``. If you already do this, invoke ``autoenv_init`` within your custom ``cd`` after sourcing ``activate.sh``.

Autoenv can be disabled via ``unset cd`` if you experience I/O issues with
certain file systems, particularly those that are FUSE-based (such as 
``smbnetfs``).
