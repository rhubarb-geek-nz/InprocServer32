# rhubarb-geek-nz/InprocServer32

Demonstration of in-process server object.

[displib.idl](displib/displib.idl) defines the dual-interface for a minimalist inproc server.

[displib.c](displib/displib.c) implements the interface.

[dispapp.cpp](dispapp/dispapp.cpp) creates an instance with [CoCreateInstance](https://learn.microsoft.com/en-us/windows/win32/api/combaseapi/nf-combaseapi-cocreateinstance) and uses it to get a message to display.

[package.ps1](package.ps1) is used to automate the building of multiple architectures.
