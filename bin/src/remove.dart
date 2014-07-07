
library pub_bin.remove;

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';

Future _removePackage(String base, String package) {
    var dir = new Directory("$base/$package");
    return dir.exists().then((exists) {
        if (!exists)
            throw new Exception("Package $package is not installed");

        List<Future> wait = [];
        return new Directory("$base/$package/bin").list().where((e) => e is File && e.path.endsWith(".dart")).forEach((e) {
            var bin = new File("/usr/local/bin/${basenameWithoutExtension(e.path)}");
            wait.add(bin.exists().then((exists) {
                if (exists) {
                    print("$package: Removing ${bin.path}");
                    return bin.delete();
                }
            }));
        })
        .then((_) => Future.wait(wait))
        .then((_) {
            print("$package: Removing package directory");
            return dir.delete(recursive: true);
        });
    });
}

remove(String base, List<String> packages) {
    if (packages.isEmpty) {
        print("No packages to remove");
        exit(1);
    }

    Future.forEach(packages, (package) {
        return _removePackage(base, package).catchError((e) {
            print(e.toString());
        });
    });
}
