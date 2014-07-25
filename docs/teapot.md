# Local Teapot Architecture

This document explains how Quill interacts with the local teapot
repository.

## Background

ActiveState maintains a server at `teapot.activestate.com` that contains 
a great number of Tcl packages, including many binary packages and all of
Tcllib.  ActiveTcl is designed to make these packages available to Tcl
scripts via a local "teapot repository".   Such a repository is
created automatically when ActiveTcl is installed; and subsequently the
`teacup` tool can be used to install packages from the server into the 
local repository.

On Linux and OS X, and I suspect on Unix in general, ActiveTcl installs 
by default into a location outside the user's home directory; and 
consequently, it will usually be installed as "root".  The local teapot
repository is installed alongside the software, and hence is also installed
as root.  And generally speaking, that means that in order to install
packages into the local repository you need to be running as root (i.e.,
you must use "sudo").  Similar problems can occur on Windows, if you don't
have "admin" privileges.

One of Quill's goals is to make managing external dependencies as easy as 
possible, and to that end Quill will query the local teapot repository and
pull required down from ActiveState's server.  Having to run Quill using
sudo is a nuisance, and contrary to the goal of making Tcl development
as easy as possible.

This document describes the way in which Quill manages the local teapot so
as to make things easier for the user.

## Quill's Own Teapot

Quill avoids the need for "sudo" or for "admin" privileges by creating 
its own local teapot in `~/.quill/teapot`.  This teapot is set to be the
default local teapot, and is linked to the development tclsh.

The following subsections explain how to make this happen.  Note that
this work will be done by Quill; the user generally won't need to do
this for himself.  Also, the following examples use Unix file and 
directory notation. Appropriate changes need to be made for Windows.

**NOTE:** If you are running on Windows with admin privileges, or if you
install ActiveTcl into your home directory, then you won't see any permissions
problems when using `teacup`, and you can avoid dealing with all this.

### Creating the Quill Teapot

To create the Quill teapot, and make it `teacup`'s default teapot:

    $ mkdir ~/.quill
    $ teacup create ~/.quill/teapot
    $ teacup default ~/.quill/teapot

None of these commands require special privileges.  If setting the 
`teacup default` causes a permissions error, update the `teacup`
executable:

    $ sudo -E teacup update-self

### Linking the Quill Teapot to the Shell

Once created, the Quill teapot must be linked to the development `tclsh`.
This is the tricky bit, as privileges are required.  On Windows, acquire 
admin privs; on OS X or Linux, use "sudo -E".  The command is shown for
Linux or OS X:

    $ sudo -e teacup link make ~/.quill/teapot /path/to/tclsh

e.g.,

    $ sudo -e teacup link make ~/.quill/teapot /usr/local/bin/tclsh

On some Linux platforms, it may be necessary to give the full path
to the `teacup` application as well:

    $ sudo -e /usr/local/bin/teacup link make ...

Once the link is established, you can check it with

    $ teacup link info ~/.quill/teapot

or
    
    $ teacup link info /path/to/tclsh

### Installing Packages into the Quill Teapot

Once the teapot has been created, made the default, and linked, it will
be used automatically by `tclsh` and `teacup`.  For example,

    $ teacup install snit 2.3

will install Snit 2.3 in the Quill teapot, and 

    $ tclsh
    % package require snit
    2.3
    %

will find Snit in the Quill teapot.  Further, `quill install` and 
`quill build` will interact with the Quill teapot automatically.

