# -*- coding: utf-8 -*-
from setuptools import setup, find_packages

setup(
    name='quill',
    packages=find_packages(),
    include_package_data=True,
    install_requires=[
        'flask',
    ],
)
