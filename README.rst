Autoenv: Dir-based Environments
==============================

I use this to auto-activate virtualenvs. Trying to keep it abstract.

It assumes you're in a bash-like environment. How pretentious.


Usage
-----

Add this to your ``shellrc``::

    $ source ~/.autoenv/activate.sh


Install
-------

Install it easily::

    $ curl https://raw.github.com/kennethreitz/autoenv/master/install.sh | sh


Disclaimer
----------

Autoenv is built upon terrible ideas.

- It overrides ``cd``. Feel free to do this yourself.
- You install it by curling into ``sh``.

Be a rebel.
