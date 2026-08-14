# C3-Assimp-Bindings

This is just a simple set of bindings that should provide you 90% of the functionality that you may need from Assimp. Obviously, extend these bindings as needed, but the vast majority of this is merely struct and enum definitions that match the Assimp side for easy usage. There are some areas that are not fully implemented (and should be marked as such), so you may need to add some additional structs and enums here and there if you need that functionality. There is also a .cpp file that needs built with your Assimp build, or it can be a separate library that you also link against. You may also simply modify the bindings to call the Assimp functions directly and you'll simply have to add extern "C" to those functions and then add the corresponding C3 bindings to `assimp.c3`. These bindings were created based on Assimp version 6.0.5.

USAGE:
There's only 4 functions defined/referenced in the bindings:

Call this to import a file and get an AiScene* back:
~~~
fn AiScene* importScene(char *fileName);
~~~

Call this when you are done with the AiScene*:
~~~
fn void cleanupScene(AiScene *scene);
~~~

If there's an error, call this:
~~~
fn char* getErrorString();
~~~

Assimp uses a struct called `aiString` for their strings.
Call this to easily convert from their string to a C3 String:
~~~
fn String stringFromAiStr(AiString aiS);
~~~

That's pretty much it.

Note 1: I've hardcoded the most common post processing flags in the .cpp file.  Feel free
to change those as needed or change the import funtion parameters to allow passing flags
directly from C3.

Note 2: most of the comments are straight from the assimp source code.
