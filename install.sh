#!/usr/bin/env bash

################################################################################
## 
## Install sa-learn-cyrus
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
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
## 
################################################################################


SCRIPT_NAME=$(basename $0)
SCRIPT_PATH=$(readlink -f "$(dirname $0)")

TOOLS="sa-learn-cyrus"
CONFS="sa-learn-cyrus.conf"
MAN_SECTION=8
BASE_PATH="/usr/local"
CONF_PATH="/etc/spamassassin"
UNINSTALL_MODE=0
REMOVE_CONFIG=0
MAN_UPDATER=`which mandb`


usage() {
	echo "Usage: ${SCRIPT_NAME} [options]"
	echo "Install sa-learn-cyrus"
	echo ""
	echo -e "Options:"
	echo -e "\t-b <path>   Installation path prefix"
    echo -e "\t            (default: $BASE_PATH)"
	echo -e "\t-c <path>   Configuration file intiallation path prefix"
    echo -e "\t            (default: $CONF_PATH)"
	echo -e "\t-u          Uninstall mode, remove a previous installation"
	echo -e "\t-f          Force overwrite or removal of existing configuration"
	echo -e "\t            files"
	echo -e "\t-h          Show this message"
	echo ""
	echo "Copyright (c) 2004-2011 Hans-Juergen Beie <hjb@pollux.franken.de>"
	echo "Copyright (c) 2020 Michael Roland <mi.roland@gmail.com>"
	echo "License GPLv3+: GNU GPL version 3 or later <http://www.gnu.org/licenses/>"
	echo ""
	echo "This is free software: you can redistribute and/or modify it under the"
	echo "terms of the GPLv3+.  There is NO WARRANTY; not even the implied warranty"
	echo "of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE."
	echo ""
}

while getopts ":h?b:c:uf" opt; do
    case "$opt" in
    h|\?)
        if [ ! -z $OPTARG ] ; then
            echo "${SCRIPT_NAME}: invalid option -- $OPTARG" >&2
        fi
        usage
        exit 1
        ;;
    b)
        BASE_PATH=$OPTARG
        ;;
    c)
        CONF_PATH=$OPTARG
        ;;
    u)
        UNINSTALL_MODE=1
        ;;
    f)
        REMOVE_CONFIG=1
        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift


if [ ! -d $BASE_PATH/bin ]; then
    echo "${SCRIPT_NAME}: $BASE_PATH/bin does not exist or is not a directory" >&2
    exit 1
fi
if [ ! -d $BASE_PATH/man ]; then
    echo "${SCRIPT_NAME}: $BASE_PATH/man does not exist or is not a directory" >&2
    exit 1
fi
if [ ! -d $CONF_PATH ]; then
    echo "${SCRIPT_NAME}: $BASE_PATH/man does not exist or is not a directory" >&2
    exit 1
fi


for toolname in $TOOLS ; do
    tool_bin="$SCRIPT_PATH/$toolname"
    tool_man="$SCRIPT_PATH/doc/$toolname.$MAN_SECTION.gz"
    install_tool_bin="$BASE_PATH/bin/$toolname"
    install_tool_man="$BASE_PATH/man/man$MAN_SECTION/$toolname.$MAN_SECTION.gz"

    if [ $UNINSTALL_MODE -eq 0 ] ; then
        if [ ! -x "$tool_bin" ] ; then
            echo "${SCRIPT_NAME}: $tool_bin was not found or is not an executable" >&2
            exit 1
        fi

        if [ ! -f "$tool_man" ] ; then
            $SCRIPT_PATH/make-doc.sh
        fi

        tool_ver=`$tool_bin --version`

        echo "Installing $toolname, version $tool_ver"
        echo "  copying $tool_bin to $install_tool_bin"
        cp "$tool_bin" "$install_tool_bin"
        chmod u=rwx,go=rx "$install_tool_bin"
        if [ ! -d "$BASE_PATH/man/man$MAN_SECTION" ]; then
            mkdir -p "$BASE_PATH/man/man$MAN_SECTION"
        fi
        echo "  copying $tool_man to $install_tool_man"
        cp "$tool_man" "$install_tool_man"
        chmod u=rw,go=r "$install_tool_man"
    else
        echo "Uninstalling $toolname, version $tool_ver"
        echo "  removing $install_tool_bin"
        rm "$install_tool_bin"
        echo "  removing $install_tool_man"
        rm "$install_tool_man"
    fi
done

$MAN_UPDATER

for confname in $CONFS ; do
    conf_file="$SCRIPT_PATH/$confname"
    install_conf_file="$CONF_PATH/$confname"

    if [ -e "$install_conf_file" ] ; then
        if [ $REMOVE_CONFIG -eq 0 ]; then
            echo "Skipping $install_conf_file, file exists"
            continue
        fi
    fi
    if [ $UNINSTALL_MODE -eq 0 ] ; then
        echo "Installing new version of $confname"
        echo "  copying $conf_file to $install_conf_file"
        cp "$conf_file" "$install_conf_file"
        chmod u=rw,go=r "$install_conf_file"
    else
        if [ -f "$install_conf_file" ] ; then
            echo "Removing existing configuration $confname"
            echo "  removing $install_conf_file"
            rm "$install_conf_file"
        fi
    fi
done
