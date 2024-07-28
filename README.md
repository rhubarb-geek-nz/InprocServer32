# rhubarb-geek-nz/InprocServer32

Demonstration of in-process server object.

```
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\AppID\{CDC09DA3-850A-45A3-B5A3-729A2D11E73D}]
@="{CDC09DA3-850A-45A3-B5A3-729A2D11E73D}"

[HKEY_CLASSES_ROOT\CLSID\{A2B77E14-CA38-4333-A85E-5DB7D4566CA2}\InprocServer32]
@="C:\\PROGRA~1\\RHUBAR~1\\INPROC~1\\x64\\RHUBAR~1.DLL"
"ThreadingModel"="Both"
```

[displib.idl](displib/displib.idl) defines the dual-interface for a minimalist inproc server.

[displib.c](displib/displib.c) implements the interface.

[dispapp.cpp](dispapp/dispapp.cpp) creates an instance with [CoCreateInstance](https://learn.microsoft.com/en-us/windows/win32/api/combaseapi/nf-combaseapi-cocreateinstance) and uses it to get a message to display.

[package.ps1](package.ps1) is used to automate the building of multiple architectures.

[dispnet.cs](dispnet/dispnet.cs) demonstrates using import library.

[dispps1.ps1](dispps1/dispps1.ps1) PowerShell creating and invoking Hello World
