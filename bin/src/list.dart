
library pub_bin.list;

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

list(String base) {
    Future previous = new Future.value();
    new Directory(base).list()
    .where((e) => e is Directory && !basename(e.path).startsWith('.'))
    .forEach((e) {
        var package = basename(e.path);
        previous.then((_) {
            return Future.wait([
                new File("$base/$package/pubspec.yaml").readAsString().then((content) {
                    var ret = loadYaml(content)['dependencies'][package];
                    if (ret is Map)
                        ret = ret['version'];
                    return ret;
                }),
                new File("$base/$package/pubspec.lock").readAsString().then((content) {
                    var pkgLock = loadYaml(content)['packages'][package];
                    if (pkgLock['source'] == "hosted")
                        return pkgLock['version'];
                    else if (pkgLock['source'] == "git")
                        return pkgLock['description']['resolved-ref'];
                })
            ])
            .then((List infos) {
                print("$package:${infos[0]} -> ${infos[1]}");
            });
        });
    });
}
