# system-policies
Configure global settings for system policies

This program should allow to create policy files using an interface instead of relying on the command line, this can be used in order for those programs to be able to use polkit/pkexec instead of gksu or sudo/su as graphical frontend. This program is in alpha stages so it might not work as expected at first, but I will try to update it on my free time. 

The idea for this program is to be a little bit like polkit-explorer and not only be able to watch the files, but also to create some policy files from scratch, also polkit-explorer is created using qt and python and I expect this to become an XApp so that you can use in many Gtk environments but being de-agnostic as well (ideally)

Credit and inspiration for the polkit-converter code goes to [this forum](https://bbs.archlinux.org/viewtopic.php?id=127648) and [this pastebin](https://pastebin.com/PbGTZ0jc), credit for this project goes to [polkit-explorer project](https://github.com/scarygliders/Polkit-Explorer)

## TO-DO
* Migrate polkit-converter code to Python (will it be possible to make it part of a Xapp library/application?)
* Create a GUI (or a library)
* Documentation
* Search on how to handle xml files in order to edit/create/view policy polkit files
* A command line tool to create those files

## Limitations
* For now it only relies on applications that are located inside /usr/bin, if the application is located on another directory (like /usr/lib for example) it won't work
* It cannot change the .desktop file on an application to the one created with the "-pkexec" suffix, but if the application works for you using pkexec (once again, *it is in alpha stages*), you can do the change manually on the desktop file, i.e: replace "app-test" on the command section of the desktop file for the equivalent "app-test-pkexec"
* Because of permissions issue (some commands are run using sudo and others not), it is suggested that the application must be run as root
