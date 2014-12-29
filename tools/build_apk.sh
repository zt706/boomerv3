#!/bin/bash
CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cp -rf "$CUR_DIR"/build_native_release.sh "$CUR_DIR"/../frameworks/runtime-src/proj.android/build_native_release.sh
$CUR_DIR/build_native_release.sh