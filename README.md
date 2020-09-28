# nQuake Server for Windows

### Docker

If you're interested in running nQuakesv in Docker, you can find the relevant projects here:

* [nQuakesv](https://github.com/nQuake/nquakesv) - Docker Compose project
* [nQuakesv Docker](https://github.com/niclaslindstedt/nquakesv-docker) - Docker server image
* [QTV Docker](https://github.com/niclaslindstedt/qtv-docker) - Docker QTV image
* [QWFWD Docker](https://github.com/niclaslindstedt/qwfwd-docker) - Docker QWFWD image

## Installation

To compile an nQuake Server installer, follow these steps:

1) Download NSIS (http://nsis.sourceforge.net/) - version 2.x or v3.0+ doesn't matter.<br>
2) Copy/move the folders in the `include` folder to `C:\Program Files (x86)\NSIS\`.<br>
_For NSIS v3.0+ you need to move the plugins (.dll files) to the "x86-ansi" subfolder of "Plugins"._<br>
3) Right-click the `nquakesv-installer_source.nsi` file and open with makensisw.exe.<br>

Tips:<br>
* Most of the code resides in `nquakesv-installer_source.nsi` but some code that is used often can be found in `nquake-macros.nsh`.<br>
* Edit the contents of the installer pages in the .ini files and their functions in the installer source file (e.g. Function DOWNLOAD for the download page).<br>

If you decide to fork nQuakesv into your own installer, I would love to get some credit, but since this is GPL I can't force you :)
