## CHANGELOG

## 0.4.0

Reads the default SuperCollider sclang_conf.yaml and merges any includePaths.
This enables support for the new Quarks system which uses includePaths instead of symlinks.
Older versions of Quarks (with symlinks) should still work.

- Update for newer Atom styling conventions
- Fix some formatting errors when error is not a simple string
- Updated example ctags grammar to match `Class : Array[slot] { }`

## 0.3.5

Fixed a bug with parsing \multiple \symbols in a line

## 0.3.4

Fixed SyntaxError display

Newer versions of sc were posting different prompts, terminal escape sequences and different messages. This was breaking the state-change detection. I fixed the reg-ex to match those better and be less fragile.

Stopped the ugly color commands intended for the terminal from ending up in the Atom console. (switched from color to chalk)

Simplified config file loading: only .supercollider.yaml or ~/.supercollider.yaml
Posts the config file that was used and a link to open it.
Posts the path of sclang that was used (determined by config file)

Windows: Home directory detection, config loading and default paths fixed.


## 0.3.0

- Runtime asynchronous errors can now be caught and full call stack shown.
  Previously only errors that were a direct response to evaluated text were shown.

- Objects in callstacks have ▶ icons. Click to unfold a full variable
  dump of each object. Very useful for debugging.

- Growl notifications on error (optional)
  see for install instructions if you need growl:
  https://github.com/visionmedia/node-growl
  ox x / linux / windows
  Very useful if you are busy making music in another window and want to know why the music just stopped.

- Server errors are colorized (eg. Node/SynthDef not found)


## 0.2.0

- Using new supercollider.js, displays a full call stack for errors
- Displays library compilation errors
- Highlights syntax and compile errors
- Brief styling flash on evaluated text with error/success colorization
- Click to navigate to errors, files, and methods
- sets nowExecutingPath correctly for sc scripts that depend on this
- Improved management of sclang's state (compile, compile error, booting)
- Enable copy from post window

## 0.1.2

Fixed 3.6.6 repl issues. Some sclang versions seem to need stripping all \n and always appending a \n at the end of the command

Fixed evaluate current line if nothing is selected

## 0.1.0 - it works !

- REPL
  + works very well with 3.7
  + 3.6.6 is a bit janky
- Post window
- GUI
- Help browser
- ctags, lookup symbols


## 0.0.0 - Init
