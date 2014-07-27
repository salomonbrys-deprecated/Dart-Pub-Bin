
library pub_bin.upgrade;

import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';

import 'pubget.dart';
import 'link.dart';

_upgradePackage(String base, String package) {
    return new Directory("$base/$package").exists().then((exists) {
        if (!exists)
            throw new Exception("Package $package is not installed");
        return pubget(base, package);
    })
    .then((_) {
        return link(base, package);
    });
}

upgrade(String base, List<String> packages) {
    if (packages.isEmpty) {
        Future previous = new Future.value();
        new Directory(base).list()
        .where((e) => e is Directory && !basename(e.path).startsWith('.'))
        .forEach((e) {
            previous = previous.then((_) {
                return _upgradePackage(base, basename(e.path)).catchError((e) {
                    print(e.toString());
                });
            });
        });
    }
    else {
        Future.forEach(packages, (package) {
            return _upgradePackage(base, package).catchError((e) {
                print(e.toString());
            });
        });
    }
}
