#!/usr/bin/env bash

################################################################################
## 
## Make documentation for sa-learn-cyrus
## 
## Copyright (C) 2004-2011 Hans-Juergen Beie <hjb@pollux.franken.de>
## Copyright (C) 2020 Michael Roland <mi.roland@gmail.com>
## 
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <https://www.gnu.org/licenses/>.
## 
################################################################################


SCRIPT_NAME=$(basename $0)
SCRIPT_PATH=$(readlink -f "$(dirname $0)")

TOOLS="sa-learn-cyrus"
MAN_SECTION=8
GZIPPER=`which gzip`


usage() {
	echo "Usage: ${SCRIPT_NAME} [options]"
	echo "Make documentation for sa-learn-cyrus"
	echo ""
	echo -e "Options:"
	echo -e "\t-h          Show this message"
	echo ""
	echo "Copyright (c) 2004-2011 Hans-Juergen Beie <hjb@pollux.franken.de>"
	echo "Copyright (c) 2020 Michael Roland <mi.roland@gmail.com>"
	echo "License GPLv3+: GNU GPL version 3 or later <https://www.gnu.org/licenses/>"
	echo ""
	echo "This is free software: you can redistribute and/or modify it under the"
	echo "terms of the GPLv3+.  There is NO WARRANTY; not even the implied warranty"
	echo "of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE."
	echo ""
}

while getopts ":h?:" opt; do
    case "$opt" in
    h|\?)
        if [ ! -z $OPTARG ] ; then
            echo "${SCRIPT_NAME}: invalid option -- $OPTARG" >&2
        fi
        usage
        exit 1
        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift


for toolname in $TOOLS ; do
    tool_bin="$SCRIPT_PATH/$toolname"
    doc_path="$SCRIPT_PATH/doc"
    doc_text="$toolname.txt"
    doc_html="$toolname.html"
    doc_man="$toolname.$MAN_SECTION.gz"

    tool_ver=`$tool_bin --version`

    echo "Building documentation for $toolname, version $tool_ver"
    if [ ! -d "$doc_path" ]; then
        mkdir -p "$doc_path"
    fi

    echo "manpage as plain text: $doc_path/$doc_text"
    $tool_bin --man-text >"$doc_path/$doc_text"

    echo "manpage in HTML format: $doc_path/$doc_html"
    $tool_bin --man-html >"$doc_path/$doc_html"

    echo "manpage: $doc_path/$doc_man"
    $tool_bin --man-manpage=$MAN_SECTION | $GZIPPER >"$doc_path/$doc_man"
done
