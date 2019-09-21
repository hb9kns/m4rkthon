#!/bin/sh

if test $# -lt 1
then cat <<EOH

usage: $0 [-n] file1 [file2 ..]
  will pass the files through m4(1) and the m4rkdown preprocessor,
  and if option '-n' is missing, feed the result to python.

m4rkdown preprocessor:
In the following, 'X' can be any of 'begin' or 'BEGIN' or '(' or '[' or '{' or '<'
and 'Y' can be any of 'end' or 'END' or ')' or ']' or '}' or '>'
(and pairs are not required to match).

1. lines beginning with '*X' or '_X' or '.X' or ';X' will increase indentation by one TAB
2. lines beginning with '*Y' or '_Y' or '.Y' or ';Y' will decrease indentation by one TAB
3. lines beginning with TAB or 4 SPC (Markdown "code") will be stripped from one TAB or 4 SPC
   and then have the current indentation prepended

EOH
exit 1
fi

if ! m4 -P </dev/null
then
 echo "**WARNING: no m4 executable found, therefore no m4 preprocessing done!**"
 M4X=cat
else
 M4X='m4 -P'
fi

if test "$1" = "-n"
then PY=cat
 shift
else PY=python
fi

indent=''

$M4X "$@" | sed -e 's/\\/\\\\/;s/^	/-:-:-/;s/^    /-:-:-/;s/^/:/' | { while read ln
do case $ln in
 :\.*|:\**|:\;*|:_*) case $ln in
  :?begin*|:?BEGIN*|:?\(*|:?\[*|:?\{*|:?\<*)
   indent="$indent	"
# echo "##### indent=$indent/"
   ;;
  :?end*|:?END*|:?\)*|:?\]*|:?\}*|:?\>*)
   indent="${indent%	}"
# echo "##### indent=$indent/"
   ;;
  *) echo "unknown m4rkdown command '${ln#:}' ignored" >&2 ;;
  esac ;;
 :-:-:-*) echo "$indent${ln#:}" ;;
 *) echo "${ln#:}" ;;
 esac
# echo ":ln=$ln$"
done
} | sed -e 's/^\(	*\)-:-:-/\1/' | $PY
