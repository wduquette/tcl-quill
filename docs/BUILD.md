# Building Quill

## Dependencies

Quill requires ActiveTcl 8.6.1 or later, and is built using
TclDevKit 5.0 or later.  It also requires access to 
[ActiveState's Teapot Repository](http://teapot.activestate.com).<p>

These tools should be installed and available on the user's PATH.<p>

## Download the Quill Source Code

Quill is hosted at [https://github.com/wduquette/tcl-quill].  You can
download or clone a particular version from there.  By convention, Quill
is cloned into `~/github/tcl-quill`, but you should be able to put it
wherever you like.  Git is not required during the build process.

Then,

```
$ cd ~/github/tcl-quill
```

Quill should be able to run as a Tcl script right out of the box; 
and everything Quill can do, it can do running as a plain Tcl script.

```
$ ./bin/quill.tcl
... (Displays help info)
```

Next, verify that it has the tools it needs.  It should be able to find
`tclsh`, `teacup`, `tclapp`:

```
$ ./bin/quill.tcl version
... (Displays version and helper tools)
```

Next, verify that your local teapot is setup properly.  It needs to be
writable by the user.  To find out, use `quill.tcl teapot`.

```
$ ./bin/quill.tcl teapot
... (Displays status of local teapot)
```

If it isn't writable, follow Quill's directions to make it so.  You might
also wish to obtain the latest `teacup` executable:

```
$ teacup update-self
```

or

```
$ sudo teacup update-self
```

Next, you will need Snit 2.3 and texutil::expander 1.3.1 in your local
teapot (they might already be there).  To find out, execute:

```
$ ./bin/quill.tcl deps
```

If necessary, you can acquire the required packages as follows:

```
$ ./bin/quill.tcl deps update
```

Next, you are ready to build Quill as an "uberkit":

```
$ ./bin/quill.tcl build
```

And then, it can be installed for use on your system:

```
$ ./bin/quill.tcl install
```

This copies `./bin/quill.kit` to `~/bin/quill` and marks it executable.
If you are on Windows and are not using a `bash` shell, you may need to
define a `quill.bat` file to invoke it.

**NOTE:** *Always* use `./bin/quill.tcl` to install any `quill.kit` you
have built yourself.  Do to the nature of Starkits and virtual file systems,
using either `./bin/quill.kit install` or `~/bin/quill install` to install
Quill itself will result in possibly messy failures.
