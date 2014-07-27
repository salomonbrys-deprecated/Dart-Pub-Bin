
library pub_bin.install;

import 'dart:io';
import 'dart:async';

import 'package:args/args.dart';

import 'pubget.dart';
import 'link.dart';

String _pubspec(String package, ArgResults args) {
    String ret = "name: _bin_$package\n";
    ret += "dependencies:\n";
    if (args['host'] != null || args['git'] != null) {
        ret += "  $package:\n";
        if (args['host'] != null) {
            ret += "    hosted:\n";
            ret += "      name: $package\n";
            ret += "      url: ${args['host']}\n";
        }
        else if (args['git'] != null) {
            ret += "    git:\n";
            ret += "      url: ${args['git']}\n";
            if (args['ref'] != null) {
                ret += "      ref: ${args['ref']}\n";
            }
        }
        ret += "    version: \"${args['version']}\"\n";
    }
    else {
        ret += "  $package: \"${args['version']}\"\n";
    }
    ret += "pub-bin:\n";
    if (args['prefix'] != null) {
        ret += "  prefix: ${args['prefix']}\n";
    }

    return ret;
}

_checkParams(ArgResults result) {
    if (result.rest.isEmpty) {
        print("Need a package to install.");
        exit(1);
    }
    else if (result['host'] != null && result['git'] != null) {
        print("You cannot set both host and git option.");
        exit(1);
    }
    else if (result['git'] != null && result['version'] != "any") {
        print("You cannot set the version option for a git package. For a git package, you can use the ref option.");
        exit(1);
    }
    else if (result['ref'] != null && result['git'] == null) {
        print("You cannot set the ref option without the git option.");
        exit(1);
    }
    else if (result['version'] != "any" && result.rest.length > 1) {
        print("You cannot set the version option for multiple packages.");
        exit(1);
    }
    else if (result['git'] != null && result.rest.length > 1) {
        print("You cannot set the git option for multiple packages.");
        exit(1);
    }
}

class _NonFatalException implements Exception {
    String _message;
    _NonFatalException(this._message);
    toString() => _message;
}

Future _installPackage(String base, ArgResults result, String package) {
    var dir = new Directory("$base/$package");
    return dir.exists()
    .then((exists) {
        if (exists) {
            throw new _NonFatalException("$package is already installed. Maybe you need to 'pub-bin update $package' ?");
        }
        else {
            print("$package: Creating directory");
            return dir.create(recursive: true);
        }
    })
    .then((_) {
        print("$package: Writing pubspec.yaml");
        var spec = new File("$base/$package/pubspec.yaml");
        return spec.writeAsString(_pubspec(package, result), flush: true);
    })
    .then((_) {
        print("$package: Creating bin dir");
        var dir = new Directory("$base/$package/bin");
        return dir.create(recursive: true);
    })
    .then((_) {
        return pubget(base, package);
    })
    .then((_) {
        return link(base, package);
    });
}

install(String base, ArgResults result) {
    _checkParams(result);
    Future.forEach(result.rest, (package) {
        return _installPackage(base, result, package).catchError((e) {
            print(e.toString());
            if (e is! _NonFatalException) {
                var dir = new Directory("$base/$package");
                return dir.exists().then((exists) {
                    if (exists)
                        return dir.delete(recursive:true);
                });
            }
        });
    });
}
