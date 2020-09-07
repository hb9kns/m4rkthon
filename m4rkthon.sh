#!/bin/sh
info="$0 // 2020/HB9KNS"

if test $# -lt 1
then cat <<EOH
$info

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
   and then have the current indentation prepended and missing colons added (see below)
4. any other lines will be removed

missing colons:
For reasons a mystery to me, Python wants colons after certain reserved words,
otherwise it throws a hissy fit. When such a word is found at the beginning of
a line (ignoring any white space before), and the line is not ending with a
colon, m4rkthon will add one. Words currently looked for are the following:
class|def|elif|else|except|for|if|try
(This simple logic fails in case of one-liners with these words;
but you probably should not use them anyway, even without m4rkthon.)

EOH
exit 1
fi

if ! m4 -P </dev/null
then
 echo "**WARNING: no m4 executable found, therefore no m4 preprocessing done!**"
 M4X=cat
else
# use m4 with extended naming for internal macros
 M4X='m4 -P'
fi

if test "$1" = "-n"
then PY=cat
 shift
else PY=python
fi

indent=''

# run through m4, escape backslashes twice (for ".." applied twice), replace
# indentation by magic mark '-:-:-' and mark beginning of line with additional ':'
$M4X "$@" | sed -e 's/\\/\\\\\\\\/;s/^	/-:-:-/;s/^    /-:-:-/;s/^/:/' | { while read ln
do case $ln in
# look for m4rkthon commands
 :\.*|:\**|:\;*|:_*) case $ln in
  :?begin*|:?BEGIN*|:?\(*|:?\[*|:?\{*|:?\<*)
# increase indentation
   indent="$indent	"
   ;;
  :?end*|:?END*|:?\)*|:?\]*|:?\}*|:?\>*)
# decrease indentation by removing last indentation
   indent="${indent%	}"
   ;;
  *) echo "unknown m4rkdown command '${ln#:}' ignored" >&2 ;;
  esac ;;
# initially indented line (already Python code): remove prepended ':'
 :-:-:-*) echo "${ln#:}" | { read w1 rest
# if first word (with indent magic mark removed) is in the list
# of special "colon words"
   case ${w1#-:-:-} in
# remove possibly already present colon at end and append (force) one
    class|def|elif|else|except|for|if|try) rest="${rest%:} :" ;;
   esac
# apply indentation and print modified line
   echo "$indent$w1 $rest"
   } ;;
# ignore all other initially non-indented lines (documentation text)
 *) ;;
 esac
done
# remove indentation magic marks
} | sed -e 's/^\(	*\)-:-:-/\1/' | $PY
