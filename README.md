# m4rkthon -- the logical extension of Python

When you come from Perl, or any decent programming language, Python's quirk of
[using the amount of whitespace for syntactical meaning][1]
seems like a joke^Whorrible idea.

But we humans use that all the time, when we organize our thoughts with indentation,
don't we? And when you use [Markdown][2], you know very well how nice that can be.

So, I did the logical step (progress never ends!) and created **m4rkthon** which
combines the best of three worlds: write your documentation right inside your code,
use `m4` macro processor commands together with Python code, or *vice versa* -- I dunno.

## File processing

1. all file arguments will be passed through `m4 -P` (or `cat` if `m4` cannot be executed)
  (i.e with requirement of `m4_` prefixes for all m4 builtin macros)
2. the concatenation of the files will be processed as defined below
3. the result will be fed to `python`

### Intermediate Processing

This will be done between `m4` and `python` processing.

In the following, `XXX` can be any of `begin` or `(` or `[` or `{` or `<`
and `YYY` can be any of `end` or `)` or `]` or `}` or `>`
(and pairs must not match).

1. lines beginning with `*XXX*` or `_XXX_` or `.XXX` will increase the indentation value by 1
2. lines beginning with `*YYY*` or `_YYY_` or `.YYY` will decrease the indentation value by 1
3. lines beginning with TAB or 4 SPC (Markdown "code") will be stripped from one TAB or 4 SPC
  and then have as many TABs prepended as the indentation value says

Any other line will be passed through unmodified.

## Examples

### ASCII code table

---

[1]: https://docs.python.org/2.0/ref/indentation.html "Indentation/Whitespace in Python"
[2]: https://daringfireball.net/projects/markdown/ "original Markdown"
