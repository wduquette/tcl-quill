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

Then, make sure you have the latest `teacup`; this comes with ActiveTcl.<p>

```
$ teacup update-self
```

or

```
$ sudo teacup update-self
```

Next, you will need to have several packages present in your local
teapot in order for Quill to build itself. You
can see the whole list in `~/github/tcl-quill/project.kite`; each
`require` statement lists one required package.

You may have some of them already.  To see what's missing, do

```
$ teacup list --at-default
```

If necessary, you can acquire the required packages as follows:

```
$ teacup install <package> <version>
```

One Quill is built, it can handle these details for you.

Then,

```
$ cd ~/github/tcl-quill
```

Once the required packages are installed, Quill should be able to run as a 
Tcl script right out of the box; and everything Quill can do, it can do 
running as a plain Tcl script.

```
$ ./bin/quill.tcl
... (Displays help info)
```

Next, verify that it can find the tools it needs.  It should be able to find
`tclsh`, `teacup`, `tclapp`:

```
$ ./bin/quill.tcl env
... (Displays its view of the environment, including the locations of all
 and helper tools)
```

If necessary, you can use the `quill config` tool to point Quill at the 
required tools.

Next, verify that your local teapot is set up properly.  It needs to be
writable by the user.  To find out, use `quill.tcl teapot`.

```
$ ./bin/quill.tcl teapot
... (Displays status of local teapot)
```

If it isn't writable, follow Quill's directions to make it so.

Quill probably  have created a new local teapot in your home directory 
during the previous step.  In that case, it will probably want to re-install
some of its require packages.  To find out, execute:

```
$ ./bin/quill.tcl deps
```

If necessary, you can acquire the required packages as follows:

```
$ ./bin/quill.tcl deps update
```

Next, you can build Quill's documentation:

```
$ ./bin/quill.tcl docs
```

Next, you are ready to build Quill as a standalone executable for your 
platform.  This also builds Quill's infrastructure library as a reusable 
package; see the `docs/` directory for the man pages.


```
$ ./bin/quill.tcl build
```

And then, it can be installed for use on your system:

```
$ ./bin/quill install
```

This copies `./bin/quill-{version}-{platform}` 
(or `./bin/quill-{version}-{platform}.exe`) 
to `~/bin/quill`, which is assumed to be on the path.  It also installs Quill's
infrastructure library into your local teapot for your use.

