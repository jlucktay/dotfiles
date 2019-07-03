#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# jq - commandline JSON processor [version 1.6]
#
#   -e               set the exit status code based on the output;
#   -r               output raw strings, not JSON texts;

ZipSecret=$(jq -er '.bash_eternal_history' "$HOME/.config/homemaker/secrets.json")

# zip --version:

# Copyright (c) 1990-2008 Info-ZIP - Type 'zip "-L"' for software license.
# This is Zip 3.0 (July 5th 2008), by Info-ZIP.
# Currently maintained by E. Gordon.  Please send bug reports to
# the authors using the web page at www.info-zip.org; see README for details.
#
# Latest sources and executables are at ftp://ftp.info-zip.org/pub/infozip,
# as of above date; see http://www.info-zip.org/ for other sites.
#
# Compiled with gcc 4.2.1 Compatible Apple LLVM 10.0.1 (clang-1001.0.37.14) for Unix (Mac OS X) on Feb 22 2019.

# Options in use:

#   -u    update   - add new files/update existing files only if later date
#   -j        junk directory names (store just file names)
#   -v        verbose operation (just "zip -v" shows version information)
#   -o        make zipfile as old as latest entry
#   -1 to -9  compress fastest to compress best (default is 6)
#   -P pswd   use standard encryption, password is pswd

#   zip options archive_name file file ...
zip -u -j -v -o -9 -P "$ZipSecret" "$ZipHere/bash_eternal_history.zip" "$HOME/.bash_eternal_history"
