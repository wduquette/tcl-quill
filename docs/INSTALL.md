# Installing Quill

To use Quill for your own projects, you can build Quill from scratch 
(see [BUILD.md]) or you can download the distribution file for your
platform from the 
[Quill Release Page at GitHub](https://github.com/wduquette/tcl-quill/releases).
This file explains how to install the distribution.

1. Download the Quill distribution for your platform, and unzip it.  It
   contains the following:

   * `README.md`
   * `bin/quill-{version}-{platform}` or `bin/quill-{version}-{platform}.exe`
   * `docs/index.html`
   * `docs/...`
   * `lib/package-quill-{version}-tcl.zip`

2. Copy the executable from `bin/` to your `~/bin` directory (or wherever
   you prefer), renaming it to `quill` or `quill.exe`.

3. Put the documentation somewhere you can find it, and bookmark 
   `docs/index.html`.

4. If desired, install the [quill(n) package](mann/index.html) into your
   local teapot.

    $ teacup install lib/package-quill-{version}-tcl.zip

5. You should now be able to enter these commands:

    $ quill help
    $ quill env

   etc.

See the README.md file for more on Quill's capabilities.
