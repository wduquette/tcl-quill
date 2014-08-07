# Quill

Quill is a build tool for Tcl/Tk projects, inspired by
[Leiningen](http://leiningen.org).  It is intended to:

* Create new skeleton project trees.
* Manage dependencies
  * External and internal
* Run tests
* Build deployment targets:
  * Standalone executables ("starpacks")
  * Lightweight executables ("starkits")
  * Reusable packages (teapot modules, .tm or .zip)
* Make it easy to build and deploy Tcl applications and libraries.
* Support formatted HTML documentation
* Run cross-platform (Windows, OS X, Linux)

## Building and Installation

To install Quill, see [docs/INSTALL.md](./docs/INSTALL.md).

To build Quill from scratch, see [docs/BUILD.md](./docs/BUILD.md).


## Basic Use Case

Assuming you have ActiveTcl 8.6.1 or later installed, with the installation's
`tclsh` on your path, you should be able to do the following:

**Download and install `quill.kit` in your ~/bin directory (or wherever).**
See [docs/INSTALL.md](./docs/INSTALL.md).

**Create a new skeleton project tree:**

```
$ cd ~/work
$ quill new app my-application myapp
...
```

**Run your new application:**

```
$ cd my-application
$ ./bin/myapp.tcl a b c
my-application 0.0a0

Args: <a b c>
```

**Run the application test suite:**

```
$ quill test
... Runs dummy test (which will fail)
```

**Build the project's HTML documentation:**

```
$ quill docs
... (You'll have to write some)
```

**Build the Application (if TDK is installed) as a .kit or standalone
executable:**

```
$ quill build
...
$ ./bin/myapp.kit a b c
my-application 0.0a0

Args: <a b c>
```

**Load the application and its libraries into Tkcon for interactive
testing:**

```
$ quill shell
... (Invokes Tkcon; does not run the application's "main" proc)
```

## Other Features

Quill can also build library packages and install them into your local
teapot repository for general use; and if your local teapot is located
somewhere that requires "root" or "admin" privileges to touch, it can
also create a new teapot repository for you in your home page.

Then, you can add `require` statements to your `project.quill` file
(created for you by `quill new`), and Quill will take care of downloading
the required packages into your local teapot when you execute 
`quill deps update`.

See the [quill(5)](./docs/man5/quill.manpage) man page for information about
the contents of the `project.quill` file, and enter `quill help` at the
command line for help on Quill and its subcommands.

## Assumptions

At present, Quill relies heavily on ActiveState's package repository
tool-chain, and particularly on "teacup" (delivered with ActiveTcl)
and "tclapp" (delivered as part of TclDevKit).  In particular, Quill
assumes the following:

* ActiveTcl 8.6.1 or later is installed on the system.
* ActiveTcl is on the path, and can be run as "tclsh" at the
  command line
* For building executables, TclDevKit 5.0 or later is installed on
  the system, and the "tclapp" tool can be run as "tclapp" at the
  command line.
* For Unix-based systems, including Mac OS X, it is assumed for
  certain operations that either ActiveTcl is installed in the
  user's home directory or the user has access to the "sudo"
  command.

## Ways to Help

I'm developing Quill on OS X, but I'm trying to write it so that will work 
on OS X, Linux, and Windows, and on Unix in general.  For Windows I'm 
expecting that Quill is being used from a MinGW bash shell rather than 
PowerShell or the basic Command Shell, but I'm trying not to rely on that.

However, I only have access to OS X.  Thus, it would be 
a great help to me to have users try it out on other platforms and submit
bug reports and patches.

Note that platform-specific code is concentrated in `lib/quillapp/plat.tcl`.
That's where Quill finds external programs like `tkcon` and `teacup`, for
example.

In addition, I've focussed on using ActiveState's "teapot" package 
repository and TclDevKit tool chain, because I have access to those.
I'm open to extending Quill to use other tool chains as well; and help
with that is also welcome.

## Acknowledgements

Thanks to the following people who have contributed bug reports, patches,
or ideas to Quill:

* effelsberg