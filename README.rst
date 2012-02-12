Autoenv: Dir-based Environments
==============================

I use this to auto-activate virtualenvs. Trying to keep it abstract.

It assumes you're in a bash-like environment. How pretentious.


What is it?
-----------

``.env`` file will automatically be excecuted when you ``cd`` into it.
This if great for...

- auto-activating virtualenvs
- project-specific environment variables
- making millions


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

    $ curl https://raw.github.com/kennethreitz/autoenv/master/install.sh | sh

Or `don't <https://raw.github.com/kennethreitz/autoenv/master/install.sh>`_.

Disclaimer
----------

Autoenv is built upon terrible ideas.

- It overrides ``cd``. Feel free to do this yourself.
- You install it by curling into ``sh``.

Be a rebel.
