#!/bin/sh
# Copyright 2016 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

###################################################
# Environment setup

export TREE_ROOT=`git rev-parse --show-toplevel`

export DART_SDK="$TREE_ROOT/third_party/flutter/bin/cache/dart-sdk"
export PATH="$DART_SDK/bin:$PATH"
export PATH="$HOME/.pub-cache/bin:$PATH"
export PATH="$TREE_ROOT/third_party/flutter/bin:$PATH"


###################################################
# Utilities

function croot() {
  cd $TREE_ROOT
}

function sync_flutter() {
  (cd $TREE_ROOT/tools/sync_flutter && pub run bin/main.dart "$@")
}

function analyze() {
  local dir=$PWD
  (cd $TREE_ROOT/tools/analyze && pub run bin/main.dart "$dir/$@")
}

function push_to_gerrit() {
  git push origin HEAD:refs/for/master
}

PRUNE_ARGS="-name third_party -prune -o -name .git -prune -o -name out -prune -o -name .pub -prune -o -name packages -prune -o -name .packages -prune -o -name build -prune"
GREP_COMMAND="grep -I -nH --color"

function sfind() {
  find . $PRUNE_ARGS -o -type f "$@" -print
}

function sgrep() {
  find . $PRUNE_ARGS -o -type f -print0 | xargs -0 $GREP_COMMAND "$@" 2>/dev/null
}

function bgrep() {
  find . $PRUNE_ARGS -o -type f -name "BUILD\.gn" -print0 | xargs -0 $GREP_COMMAND "$@" 2>/dev/null
}

function jgrep() {
  find . $PRUNE_ARGS -o -type f -name "*\.java" -print0 | xargs -0 $GREP_COMMAND "$@" 2>/dev/null
}

function pgrep() {
  find . $PRUNE_ARGS -o -type f -name "*\.py" -print0 | xargs -0 $GREP_COMMAND "$@" 2>/dev/null
}

function dgrep() {
  find . $PRUNE_ARGS -o -type f -name "*\.dart" -print0 | xargs -0 $GREP_COMMAND "$@" 2>/dev/null
}

function specgrep() {
  find . $PRUNE_ARGS -o -type f -name "pubspec.yaml" -print0 | xargs -0 $GREP_COMMAND "$@" 2>/dev/null
}

function mojgrep() {
  find . $PRUNE_ARGS -o -type f -name "*\.mojom" -print0 | xargs -0 $GREP_COMMAND "$@" 2>/dev/null
}

function cgrep() {
  find . $PRUNE_ARGS -o -type f \( -name "*\.cc" -o -name "*\.c" -o -name "*\.h" \) -print0 | xargs -0 $GREP_COMMAND "$@" 2>/dev/null
}

function sysui_help() {
  echo ""
  echo "----- SysUI command line tools -----"
  echo ""
  echo " >>> Environment variables <<<"
  echo "DART_SDK"
  echo "PATH"
  echo ""
  echo " >>> Commands <<<"
  echo "croot           - cd to the root of the Git tree"
  echo "sync_flutter    - inspect and sync new commits in Flutter"
  echo "sfind           - find files in the tree"
  echo "analyze         - analyze Dart code"
  echo "push_to_gerrit  - push current HEAD to Gerrit for review"
  echo ""
  echo " >>> Search commands"
  echo "sgrep           - search through all files"
  echo "bgrep           - search through BUILD files"
  echo "jgrep           - search through Java files"
  echo "pgrep           - search through Python files"
  echo "dgrep           - search through Dart files"
  echo "specgrep        - search through pubspec files"
  echo "mojgrep         - search through Mojom files"
  echo "cgrep           - search through C/C++ files"
  echo ""
}
