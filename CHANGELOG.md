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
