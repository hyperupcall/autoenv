#!/usr/bin/env python
"""Pythonic Setup for autoenv."""


import setuptools


def readme():
    with open("README.md") as f:
        README = f.read()
    return README


setuptools.setup(
    version='0.2.1',
    name='autoenv',
    description='Directory-based environments.',
    long_description=readme(),
    long_description_content_type="text/markdown",
    author='Nishchith Shetty',
    author_email='inishchith@gmail.com',
    license='See LICENSE.',
    url='https://github.com/inishchith/autoenv',
    scripts=['activate.sh'],
)
