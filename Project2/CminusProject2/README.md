CMinusCompiler
==============

This is a C minus compiler that translates a new language "C minus" to x86_64 assembly. Not a true compiler, but pretty close. Worked on this through out the entire semester.


This compiler uses dlink and sym_tab data structures made for C. Using flex and bison to symbolize and parse the C minus files and generate assembly code.
The x86_64 assembly is tested on a fedora distro of linux.


ToDo
====
Update x86_64 for Mac OS X