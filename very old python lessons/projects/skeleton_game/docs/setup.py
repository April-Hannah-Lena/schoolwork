try:
	from setuptools import setup
except ImportError:
	from distutils.core import setup

config = {
	'description': 'game',
	'author': 'April Herwig',
	'version': '0.1',
	'install requires': ['nose'],
}

setup(**config)
