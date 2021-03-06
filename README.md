# Quill

Quill is a project automation tool for Tcl/Tk projects, inspired by
[Leiningen](http://leiningen.org).  It is intended to make it easy to 
build and deploy Tcl applications and libraries.  In particular,
Quill:

* Creates new skeleton project trees.
* Runs test suites
* Formats HTML documentation
* Manages dependencies
  * External and internal
* Executes your project in development
* Supports interactive development
* Executes arbitrary scripts in the context of your project's code base
* Builds deployment targets:
  * Standalone executables ("starpacks")
  * Lightweight executables ("starkits")
  * Reusable packages (teapot .zip modules)
* Builds distribution .zip files
* Runs cross-platform (Windows, OS X, Linux)

As such, it is intended to reduce the ancillary costs of defining and
deploying a Tcl package or executable to as close to zero as possible, by
automating everything but the actual writing of the code and documentation. 

You can follow Quill development at
[GitHub](https://github.com/wduquette/tcl-quill); also, I'm posting 
occasional development notes and questions for the Quill users on 
[my blog](http://www.foothills.wjduquette.com/blog/).

## Building and Installation

To install Quill, see [docs/INSTALL.md](./docs/INSTALL.md).

To build Quill from scratch, see [docs/BUILD.md](./docs/BUILD.md).


## Basic Use Case

Assuming you have ActiveTcl 8.5 or later installed, with the installation's
`tclsh` on your path, you should be able to do the following:

**Download and install `quill.exe` in your ~/bin directory (or wherever).**
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

** Install your application and libraries for local use:**

```
$ quill install
... (Copies the executable to your ~/bin, and libraries to your teapot)
```

## Other Features

Quill can also build library packages and install them into your local
teapot repository for general use; and if your local teapot is located
somewhere that requires "root" or "admin" privileges to touch, it can
also create a new teapot repository for you in your home directory.

Then, you can add `require` statements to your `project.quill` file
(created for you by `quill new`), and Quill will take care of downloading
the required packages into your local teapot when you execute 
`quill deps update`.

Finally, if you define a distribution in `project.quill`, Quill will build
the distribution .zip file for you.

See the [project(5)](./docs/man5/project.manpage) man page for information 
about the contents of the `project.quill` file, and enter `quill help` at the
command line for help on Quill and its subcommands.

## Dependencies

How much Quill can do for you depends on what ancillary tools you have 
installed.  You will need a Tcl interpreter at the very least.

With just an arbitrary Tcl interpreter, Quill can:

* Create new project trees for you.
* Run your tests
* Format your documentation
* Make it easier to run your code, either from the system command line or 
  from an interactive Tcl shell.
* Create distribution .zip files.

With [ActiveTcl](http://www.activestate.com/activetcl), Quill can:

* Manage external dependencies, pulling packages from ActiveState's
  teapot repository and keeping them up to date in your environment.

With [TclDevKit 5.3](http://www.activestate.com/tcl-dev-kit), Quill can:

* Build standalone executables for Linux, OS X, and Windows
* Build libraries as teapot packages, for installation into a local
  teapot repository. 

## Ways to Help

I'm developing Quill on OS X, but I'm trying to write it so that will work 
on OS X, Linux, and Windows, and on Unix in general.  For Windows I'm 
expecting that Quill is being used from a MinGW bash shell rather than 
PowerShell or the basic Command Shell, but I'm trying not to rely on that.

However, I only have access to OS X.  Thus, it would be 
a great help to me to have users try it out on other platforms and submit
bug reports and patches.

In addition, I've focussed on using ActiveState's "teapot" package 
repository and TclDevKit tool chain, because I have access to those.
I'm open to extending Quill to use other tool chains as well; and help
with that is also welcome.

## Acknowledgements

Thanks to the following people who have contributed bug reports, patches,
or ideas to Quill, or helped in other ways:

* Ted Brunzie
* Stephan Effelsberg
* Andreas Kupries

