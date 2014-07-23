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

Working splendidly with SuperCollider 3.7 (development build) and 3.6.6 (latest stable release)

---

### Installation

##### 1. Install this package:

    apm install supercollider

or do it using Atom's 'Install Packages'


##### 2. Download and install SuperCollider:

https://supercollider.github.io

##### 3. It should work

If you've installed SuperCollider in a non-standard place or have a development build, then create a .supercolliderrc file to specify the path

See "Preferences" below.

##### 4. Open an .scd file in an Atom project and then open a post window (shift-cmd-k)

---

### REPL

| key              | command                                         |
| ---------------- | ----------------------------------------------- |
| `cmd-\`          | Open post window, boot the language interpreter |
| `shift-cmd-k`    | Compile library (open window if needed)         |
| `shift-enter`    | Evaluate selection or current line              |
|                  | Clear post window                               |
| `cmd-.`          | Panic ! Stop all music                          |


You may customize these in your own Keymap file.


### Lookup classes and methods with `shift-cmd-r`

Lookup is done using Atom's Symbol View which is powered by the venerable ctags

Install ctags if you need to:

    brew install ctags

Add this support for supercollider to your ~/.ctags

    --langdef=supercollider
    --langmap=supercollider:.sc
    --regex-supercollider=/^([A-Z]{1}[a-zA-Z0-9_]*) /\1/c,class/
    --regex-supercollider=/^[[:space:]]*(\*[a-z]{1}[a-zA-Z0-9_]*) \{/\1/m,method/
    --regex-supercollider=/^[[:space:]]*([a-z]{1}[a-zA-Z0-9_]*) \{/\1/m,method/

- Symlink quarks and the SCClassLibrary into your project directory
- Install `symbol-gen` package
- Regenerate tags with `cmd-alt-g`
- `shift-cmd-r` will now be able to find all classes and methods
- Select a classname, `alt-cmd-down_arrow` to go to the definition

Best practice is to symlink the Extensions and SCClassLibrary into your current project directory. Then all Classes will be indexed and easy to look up.

There is also a package called 'goto' that uses the language grammar to generate symbols rather than ctags.  If you do a lot of non-class development then this might be a useful approach. I find it tags too much junk, and I like having just classes and methods in my tags file.

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
      "path": "/path/to/SuperCollider.app/Contents/Resources"
    }

It will search upwards starting with the current Atom project root. So you can set your current project to a custom SuperCollider by placing a .supercolliderrc there

##### Default paths:

**OS X**

`"/Applications/SuperCollider/SuperCollider.app/Contents/Resources"`

**Linux**

`"/usr/local/bin"`

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
