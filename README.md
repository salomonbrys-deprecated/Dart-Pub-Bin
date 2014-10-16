DEPRECATED
==========

This package has been (greatly) deprecated by Dart 1.7.0's pub feature to *activate* packages.


dart-pub-bin
============

Pub installer for bin packages


Description
-----------

pub bin is much like `npm install -g` for nodejs. It allows you to globaly install binaries that are defines in dart packages.


Installation
------------

At the moment, pub-bin only works in linux and Mac OS X.

You can install pub-bin as user or as root.
It is recommended to install pub-bin as user if you have the right to write to /usr/local and /usr/local/bin :

    curl -s https://raw.githubusercontent.com/SalomonBrys/dart-pub-bin/master/install.sh | bash

If you have a Permission Denied error, you can install pub-bin as root :

    curl -s https://raw.githubusercontent.com/SalomonBrys/dart-pub-bin/master/install.sh | sudo env "PATH=$PATH" bash

The `install.sh` will install pub-bin in a temporary directory then use this pub-bin to install pub-bin.


Usage
-----

To install a package hosted on [pub.dartlang.org](http://pub.dartlang.org), simply run:

    pub-bin install package

You can also install a specific package but prefix its binaries:

    pub-bin install package -p prefix

To install a specific version of the package, use a version constraint:

    pub-bin install package -v ">=1.2.0 <2.0.0"

If the package is hosted on an other pub hosting service:

    pub-bin install -h "http://my.hosting-service.com" package
  
If the package is hosted in a git repository:

    pub-bin install -g git://repository.com/package.git package

If you want a specific commit, branch or tag:

    pub-bin install -g git://repository.com/package.git package -r v1.2


Examples
--------

To install [dake](https://github.com/SalomonBrys/Dart-dake):

    pub-bin install dake
  
You will then have the `dake` binary installed.

To install [coverage](https://github.com/dart-lang/coverage) but have binaries prefixed with `cov-`:

    pub-bin install coverage -p cov-

You will then have both `cov-collect_coverage` and `cov-format_coverage` binaries installed.


