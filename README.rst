Autoenv: Directory-based Environments
======================================

Magic per-project shell environments. Very pretentious.


What is it?
-----------

If a directory contains a ``.env`` file, it will automatically be excecuted
when you ``cd`` into it.

This is great for...

- auto-activating virtualenvs
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

Install it easily::

    $ git clone git://github.com/kennethreitz/autoenv.git ~/.autoenv
    $ echo 'source ~/.autoenv/activate.sh' >> ~/.bashrc


Testing
-------

Install dtf::

    $ gem install dtf --version 0.1.1 # verbose output
    $ gem install dtf --version 0.1.2 # dotted output

Test::

    $ dtf test/*


Disclaimer
----------

Autoenv overrides ``cd``. If you already do this, invoke ``autoenv_init`` within your custom ``cd``.
Make sure your cd override is defined after sourcing activate.sh.
