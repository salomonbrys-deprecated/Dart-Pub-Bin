
library pub_bin;

import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';

import 'src/install.dart';
import 'src/upgrade.dart';
import 'src/list.dart';
import 'src/remove.dart';

main(List<String> args) {
    String base = dirname(dirname(dirname(Platform.script.path)));
    if (Platform.environment.containsKey("PUB_BIN_BASE"))
        base = Platform.environment["PUB_BIN_BASE"];

    var parser = new ArgParser();
    parser.addFlag("help", help: "This help", negatable: false);

    Map<ArgParser, String> defs = {};

    var installParser = parser.addCommand("install", new ArgParser(allowTrailingOptions: true));
    defs[installParser] = "package [additional-packages]";

    installParser.addOption("host", abbr: "h", help: "The host package server if the package is not hosted on pub.dartlang.org");
    installParser.addOption("version", abbr: "v", help: "The version constraint of the package", defaultsTo: "any");
    installParser.addOption("git", abbr: "g", help: "The git HTTP url of the package");
    installParser.addOption("ref", abbr: "r", help: "The git reference of the package");
    installParser.addOption("prefix", abbr: "p", help: "Prefix for binary packages");

    var upgradeParser = parser.addCommand("upgrade", new ArgParser(allowTrailingOptions: true));
    defs[upgradeParser] = "[packages]";

    parser.addCommand("list");

    var removeParser = parser.addCommand("remove");
    defs[upgradeParser] = "package [additional-packages]";


    var result = parser.parse(args);

    if (result.command == null || result['help']) {
        print("pub-bin [option] command [params]");
        print(parser.getUsage());
        parser.commands.forEach((name, cmd) {
            print("");
            if (defs.containsKey(cmd))
                print("  $name ${defs[cmd]}");
            else
                print("  $name");
            print(cmd.getUsage().split("\n").map((line) => "    $line").join("\n"));
        });
        exit(0);
    }

    if (result.command.name == "install")
        install(base, result.command);

    if (result.command.name == "upgrade")
        upgrade(base, result.command.rest);

    if (result.command.name == "list")
        list(base);

    if (result.command.name == "remove")
        remove(base, result.command.rest);
}
