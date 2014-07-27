
library pub_bin.pubget;

import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';

Future pubget(base, package) {
    String pubExec = "pub";
    String platformDir = dirname(Platform.executable);
    if (platformDir.startsWith("/"))
        pubExec = "$platformDir/pub";
    print("$package: Running pub get");
    return Process.start(pubExec, ["get"], workingDirectory: "$base/$package", environment: {'PUB_CACHE': "$base/.pub-cache"})
    .then((process) {
        stdout.addStream(process.stdout);
        stderr.addStream(process.stderr);
        return process.exitCode;
    })
    .then((code) {
        if (code != 0)
            throw new Exception("Pub get ended with error $code");
    })
    .then((_) {
        return Process.run("find", ["$base/.pub-cache/", "-type", "d", "-exec", "chmod", "755", "{}", ";"]);
    })
    .then((_) {
        return Process.run("find", ["$base/.pub-cache/", "-type", "f", "-exec", "chmod", "644", "{}", ";"]);
    })
    ;

}