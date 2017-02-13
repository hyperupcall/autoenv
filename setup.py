#!/usr/bin/env python
"""Pythonic Setup for autoenv."""


import setuptools


setuptools.setup(
    version='2.0.0',
    name='autoenv',
    description='Directory-based environments.',
    author='Kenneth Reitz',
    author_email='_@kennethreitz.com',
    license='See LICENSE.',
    url='https://github.com/kennethreitz/autoenv',
    scripts=['activate.sh'],
)
