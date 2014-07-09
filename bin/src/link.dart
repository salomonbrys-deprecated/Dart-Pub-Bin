
library pub_bin.link;

import 'dart:io';
import 'dart:async';

import 'package:yaml/yaml.dart';
import 'package:path/path.dart';

String _encode(String uri) {
    String ret = "";
    List<int> exceptions = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~'.runes.toList(growable: false);
    uri.runes.forEach((code) {
        if (exceptions.contains(code))
            ret += new String.fromCharCode(code);
        else
            ret += "%$code";
    });
    return ret;
}

String _getPathFromPubspecLock(String base, String content, String package) {
    var pkgLock = loadYaml(content)['packages'][package];

    var path = "$base/.pub-cache/${pkgLock['source']}/";
    if (pkgLock['source'] == "hosted") {
        var host = "pub.dartlang.org";
        if (pkgLock['description'] is Map) {
            if ((pkgLock['description'] as Map).containsKey('url')) {
                host = _encode((pkgLock['description']['url'] as String).split("://")[1]);
            }
        }
        path += "$host/$package-${pkgLock['version']}";
    }
    else if (pkgLock['source'] == "git") {
        path += "$package-${pkgLock['description']['resolved-ref']}";
    }
    else {
        throw new Exception("Unknown hosting source");
    }
    return path;
}

Future link(String base, String package) {
    List<Future> wait = [];
    List<String> oldDarts = [];
    List<String> newDarts = [];
    Map options = {};

    print("$package: Reading pubspec.yaml");
    return new File("$base/$package/pubspec.yaml").readAsString().then((content) {
        Map yaml = loadYaml(content);
        if (yaml.containsKey("pub-bin") && yaml["pub-bin"] is Map)
            options = yaml["pub-bin"];
    })
    .then((_) {
        print("$package: Deleting old links");
        return new Directory("$base/$package/bin").list().where((e) => basename(e.path) != "packages").forEach((FileSystemEntity e) {
            if (e is File && basename(e.path).endsWith(".dart"))
                oldDarts.add(basenameWithoutExtension(e.path));
            wait.add(e.delete());
        });
    })
    .then((_) => Future.wait(wait))
    .then((_) {
        print("$package: Reading pubspec.lock");
        return new File("$base/$package/pubspec.lock").readAsString().then((content) {
            var path = _getPathFromPubspecLock(base, content, package);
            wait = [];
            print("$package: Creating new links");
            return new Directory("$path/bin").list().forEach((e) {
                if (e is File && basename(e.path).endsWith(".dart"))
                    newDarts.add(basenameWithoutExtension(e.path));
                var link = new Link("$base/$package/bin/${basename(e.path)}");
                wait.add(link.create(e.path));
            });
        });
    })
    .then((_) => Future.wait(wait))
    .then((_) {
        String prefix = options.containsKey('prefix') ? options['prefix'] : '';
        wait = [];
        oldDarts.where((e) => !newDarts.contains(e)).forEach((String name) {
            print("$package: Deleting /usr/local/bin/$prefix$name");
            wait.add(new File("/usr/local/bin/$prefix$name").delete());
        });
        newDarts.where((e) => !oldDarts.contains(e)).forEach((String name) {
            print("$package: Creating /usr/local/bin/$prefix$name");
            var bin = new File("/usr/local/bin/$prefix$name");
            wait.add(bin.exists()
                .then((bool exists) {
                    if (exists)
                        return bin.delete();
                })
                .then((_) {
                    return bin.writeAsString("#!/bin/sh\n${Platform.executable} $base/$package/bin/$name.dart \"\$@\"\n", flush: true);
                })
                .then((_) {
                    return Process.run("chmod", ["+x", bin.path]);
                })
            );
        });
        return Future.wait(wait);
    });
}
