Lua spell-correct
=================

Lua implementation of [spelling corrector](http://norvig.com/spell-correct.html)
example developed in Python by Peter Norvig.

It has been implemented as a Lua module, so it can be loaded by using `require`.
The following files are available:

- `spell.lua` is the Lua module with the spelling corrector functions.

- `corrector.lua` is a Lua script which loads the data and allows to perform
  on-line corrections.

- `test.lua` has both tests sugested by Peter Norvig to measure the performance
  of the implementation.

Example of use
==============

You need to download [big.txt](http://norvig.com/big.txt).

For on-line spelling corrector:

```
$ lua correct.lua
Enter a word (ctrl+d exits): somethig   
Sugestion:	something
Enter a word (ctrl+d exits): 
```

For run the tests prepared by Peter Norvig:

```
$ lua test.lua
{ "bad": 68, "bias": nil, "unknown": 15, "secs": 13, "pct": 74, "n": 270,  }
{ "bad": 130, "bias": nil, "unknown": 43, "secs": 24, "pct": 67, "n": 400,  }
```
