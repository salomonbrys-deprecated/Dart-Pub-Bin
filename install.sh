#!/bin/sh

TMP=/tmp/pub-bin-install

function checkCommand() {
    which $1 > /dev/null 2>&1
    if [ $? != 0 ]; then
	echo "Could not find $1. Is the dart SDK in the PATH?"
	echo "$PATH"
	exit 1
    fi
}

checkCommand dart
checkCommand pub

DART=$(which dart)

rm -rf $TMP

mkdir -p $TMP
cd $TMP

cat <<EOF > pubspec.yaml
name: pub_bin_tmp
dependencies:
  pub_bin: any
EOF

PUB_CACHE=$TMP/.pub-cache pub get

ln -s $TMP/.pub-cache/hosted/pub.dartlang.org/pub_bin-*/bin/* .

PUB_BIN_BASE=/usr/local/pub-bin $DART ./pub-bin.dart install pub_bin

rm -rf $TMP
