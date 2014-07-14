# SuperCollider for Atom

A SuperCollider development environment for Atom.io

---

SuperCollider is a programming language for real time audio synthesis and algorithmic composition.

https://supercollider.github.io

---

1. SuperCollider comes with a cross platform **IDE** (OS X/Linux/Windows) which communicates with the language interpreter.

2. The language interpreter runs in a separate process (**sclang**) and includes comprehensive bindings for making Qt based GUIs. sclang compiles and executes SuperCollider code, manages event schedulers (for making music) and creates GUIs. It can also send and receive OSC (Open Sound Control) and MIDI.

3. The SuperCollider synthesis server (**scsynth**) runs in a separate process or even on a separate machine so it is ideal for realtime networked music. It just makes music, its quite efficient and the audio quality is very high. Communication between sclang and scsynth is via OSC (Open Sound Control).

SuperCollider Atom is an alternative to the IDE. Atom is free, open source and very hackable.

---

**Status: Beta**

Working splendidly with SuperCollider 3.7 (development build)

The latest official release (3.6.6) has some issues still.

---

### Installation

Install atom-supercollider

    apm install atom-supercollider

Download and install SuperCollider:

https://supercollider.github.io

Unless you've installed SuperCollider in a non-standard place, then atom-supercollider should find sclang and scsynth and just work.

Open an .scd file in an Atom project and then open a post window (shift-cmd-k)

See preferences below to set a custom path or to switch between SuperCollider versions

---

### REPL

`cmd-\`           Open post window, boot the language interpreter

`shift-cmd-k`     Compile library (open window if needed)

`shift-enter`     Evaluate selection

`(not assigned)`  Clear post window

`cmd-.`           Panic ! Stop all music

You may customize these in your own Keymap file.


### Lookup classes and methods with `shift-cmd-r`

Install ctags if you need to:

    brew install ctags

Add this to your ~/.ctags

    --langdef=supercollider
    --langmap=supercollider:.sc
    --regex-supercollider=/^([A-Z]{1}[a-zA-Z0-9_]*) /\1/c,class/
    --regex-supercollider=/^[[:space:]]*(\*[a-z]{1}[a-zA-Z0-9_]*) \{/\1/m,method/
    --regex-supercollider=/^[[:space:]]*([a-z]{1}[a-zA-Z0-9_]*) \{/\1/m,method/

- Symlink quarks and the SCClassLibrary into your project directory
- Install `symbol-gen` package
- Regenerate tags with `cmd-alt-g`
- `shift-cmd-r` will now be able to find all classes and methods

### GUI

SuperCollider has a comprehensive Qt based gui toolkit.  GUIs in SuperCollider Atom work just as they do with the SCIDE, they run in the separate language process:

    Server.default.gui

### Help files:

cmd-shift-p  and type "open help file..."

Or use the context menu (right-click)

The help browser will open in a new window.


(TODO: open help files directly in Atom)

## Preferences

To set a custom path to sclang and scsynth create a JSON file in ~/.supercolliderrc

    {
      "path": "/path/to/SuperCollider.app"
    }

It will look up the directory tree starting with the current Atom project root. So you can open separate projects that specify different SuperColliders.

##### Default paths:

**OS X**

"/Applications/SuperCollider/SuperCollider.app/Contents/Resources/"

**Linux**

"/usr/local/bin"

**Windows**

Not sure, somebody please let me know.





## Missing Features

#### Built in server window

    s = Server.default;

    // but its easy to make a server window
    s.makeWindow

    // if you have cruciallib installed
    s.gui

#### Native Auto-complete

There are many Atom packages for auto-complete. However they use text matching and not direct introspection.
