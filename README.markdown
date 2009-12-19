[Sanguine](http://github.com/jpld/Sanguine/)
=============
quartz composer plug-in which executes MacRuby with an arbitrary number of input and output parameters. the plug-in needs to run in a garbage collected host, as MacRuby runs in the ObjC Runtime and requires GC to unify Ruby and ObjC memory management. the quartz composer editor **does not** currently support GC, a separate host should be used.

requires MacRuby framework at build and run time.
[MacRuby](http://www.macruby.org/)
