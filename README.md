# m4rkthon -- the logical extension of Python

When you come from Perl, or any decent programming language, Python's quirk of
[using the amount of whitespace for syntactical meaning][1]
seems like a joke^Whorrible idea.

But we humans use that all the time, when we organize our thoughts with indentation,
don't we? And when you use [Markdown][2], you know very well how nice that can be.

So, with the aim for neverending progress of mankind, **m4rkthon** was created, which
combines the best of three worlds: write your documentation right inside your code, and
use `m4` macro processor commands together with Python code, or *vice versa* -- whatever.

## File processing

The `m4rkthon` script accepts the option `-n` and one or more file arguments.
Option `-n` results in only the first two of the following steps, i.e only
m4 and intermediate processing, without launching `python.`
This can be used to verify what would be fed to Python.

1. all file arguments will be passed through `m4 -P` (or `cat` if `m4` cannot be executed)
  (i.e with requirement of `m4_` prefixes for all m4 builtin macros)
2. the concatenation of the files will be processed as defined below
3. the result will be fed to `python`

### Intermediate Processing

This will be done between `m4` and `python` processing.

In the following, `X` can be any of `begin` or `BEGIN` or `(` or `[` or `{` or `<`
and `Y` can be any of `end` or `END` or `)` or `]` or `}` or `>`
(and pairs are not required to match).

1. lines beginning with `*X` or `_X` or `.X` or `;X` will increase indentation by one TAB
2. lines beginning with `*Y` or `_Y` or `.Y` or `;Y` will decrease indentation by one TAB
3. lines beginning with TAB or 4 SPC (Markdown "code") will be stripped from one TAB or 4 SPC
   and then have the current indentation prepended

Any other line will be passed through unmodified.

## Example: printable ASCII table

(for Python3)

	m4_define(YO,print)m4_dnl
	m4_define(FEED,`print ()')m4_dnl
	m4_define(NOFEED,`end=""')m4_dnl
	m4_define(SKAN,for $1 in range($2,$3):
	.BEGIN)m4_dnl
	m4_define(NAKS,pass
	.END)m4_dnl
	#
	# Da ASCII taybl!
		YO ("# ASCII")
		FEED
		YO ('\t  /',0,1,2,3,4,5,6,7,8,9,'a','b','c','d','e','f')
		SKAN(z,2,8)
		YO ('\t',z,' ', NOFEED)
		SKAN(s,0,16)
		YO (chr(16*z+s)+' ', NOFEED)
		NAKS
		FEED
		NAKS
		FEED

saved as `test.m4t` and processed with `m4rkthon.sh -n test.m4t` will give

	#
	# Da ASCII taybl!
	print ("# ASCII")
	print ()
	print ('\t  /',0,1,2,3,4,5,6,7,8,9,'a','b','c','d','e','f')
	for z in range(2,8):
		print ('\t',z,' ', end="")
		for s in range(0,16):
			print (chr(16*z+s)+' ', end="")
			pass
		print ()
		pass
	print ()

and processed with `m4rkthon.sh test.m4t` will result in

	# ASCII
	
		  / 0 1 2 3 4 5 6 7 8 9 a b c d e f
		 2    ! " # $ % & ' ( ) * + , - . / 
		 3  0 1 2 3 4 5 6 7 8 9 : ; < = > ? 
		 4  @ A B C D E F G H I J K L M N O 
		 5  P Q R S T U V W X Y Z [ \ ] ^ _ 
		 6  ` a b c d e f g h i j k l m n o 
		 7  p q r s t u v w x y z { | } ~  
	
Of course, the command `NAKS` defined as an m4 macro could be used as closing command
for any block, as it is reducing indentation in general and not only related to `SKAN.`

[1]: https://docs.python.org/2.0/ref/indentation.html "Indentation/Whitespace in Python"
[2]: https://daringfireball.net/projects/markdown/ "original Markdown"
