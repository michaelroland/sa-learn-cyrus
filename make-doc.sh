#!/bin/sh
#
# make documentation (manpage) from pod
#
# hjb -- 2008-03-22

name=sa-learn-cyrus
source=./$name
version=`$source --version`
man_section=8

if [ ! -x $source ]; then
    echo Cannot find $source
    echo Start this script in the same directory where $name is located.
    exit 1
fi  

echo making documentation for $name-$version

# text documentation
text_manpage=doc/$name.txt
echo manpage as plain text: $text_manpage
$source --man-text > $text_manpage

# html documentation
html_manpage=doc/$name.html
echo manpage in html format: $html_manpage
$source --man-html > $html_manpage

# manpage
manpage=doc/$name.$man_section
echo manpage: $manpage
$source --man-manpage=$man_section > $manpage
gzip=`which gzip`
$gzip -f $manpage
